{
  pkgs,
  extraContents ? [ ],
  extraEnv ? [ ],
}:
let
  inherit (pkgs) writeTextFile runCommand;
  inherit (pkgs)
    dockerTools
    bashInteractive
    cacert
    coreutils
    curl
    git
    gnutar
    gzip
    iana-etc
    nix
    openssh
    xz
    linux-pam
    shadow
    sudo
    ;

  # ==========================================
  # ✨ 真正安全的 su 捕获逻辑
  # ==========================================
  suBinPackage = runCommand "container-su-bin" { } ''
    mkdir -p $out/bin

    # 动态探测当前 Nixpkgs 中 su 究竟被藏在了哪个包里
    # 优先去标准的共用系统包中搜寻
    for pkg in ${pkgs.su or pkgs.util-linux} ${pkgs.shadow}; do
      if [ -f "$pkg/bin/su" ]; then
        cp "$pkg/bin/su" $out/bin/su
        chmod +x $out/bin/su
        exit 0
      elif [ -f "$pkg/sbin/su" ]; then
        cp "$pkg/sbin/su" $out/bin/su
        chmod +x $out/bin/su
        exit 0
      fi
    done

    # 如果实在找不到，用 busybox 的 su 或者向导抛错，防止无脑编译通过后进去还是空的
    echo "ERROR: Cannot find su binary in specified packages!" >&2
    exit 1
  '';

  # ==========================================
  # PAM 自动化生成
  # ==========================================
  basePamContent = ''
    auth      required  pam_unix.so
    account   required  pam_unix.so
    session   required  pam_unix.so
  '';

  pamRemoteLogin = writeTextFile {
    name = "pam-system-remote-login";
    destination = "/etc/pam.d/system-remote-login";
    text = basePamContent;
  };

  makePamFile =
    name:
    writeTextFile {
      inherit name;
      destination = "/etc/pam.d/${name}";
      text = ''
        auth      include   system-remote-login
        account   include   system-remote-login
        session   include   system-remote-login
      '';
    };

  pamSudo = makePamFile "sudo";
  pamSshd = makePamFile "sshd";
  pamSu = makePamFile "su";

  sudoers = writeTextFile {
    name = "sudoers";
    destination = "/etc/sudoers";
    text = "%wheel ALL=(ALL) NOPASSWD: ALL\n";
  };

  # Entrypoint 保持动态高可用
  entrypoint = writeTextFile {
    name = "entrypoint";
    destination = "/entrypoint.sh";
    executable = true;
    text = ''
      #!/bin/sh
      mkdir -p /run/sshd /run/systemd /etc/ssh

      if [ -f /etc/sudoers ]; then
        chmod 0440 /etc/sudoers 2>/dev/null || true
      fi

      cat << 'EOF' > /etc/ssh/sshd_config
      Port 22
      ListenAddress 0.0.0.0
      PasswordAuthentication yes
      PermitRootLogin yes
      Subsystem sftp internal-sftp
      EOF

      ${openssh}/bin/ssh-keygen -A 2>/dev/null

      # 运行时创建用户与组
      ${shadow}/bin/groupadd -f wheel
      if ! id -u x >/dev/null 2>&1; then
        ${shadow}/bin/useradd -m -u 1000 -G wheel -s /bin/bash x 2>/dev/null
      fi
      echo "x:x" | ${shadow}/bin/chpasswd

      exec ${openssh}/bin/sshd -D
    '';
  };

in
dockerTools.buildImageWithNixDb {
  inherit (nix) name;

  contents = [
    ./root
    coreutils
    bashInteractive
    nix
    cacert
    git
    gnutar
    gzip
    openssh
    xz
    curl
    iana-etc

    # 必需的安全套件
    linux-pam
    shadow
    sudo

    # 注入动态生成的 su 二进制层
    suBinPackage

    # 注入配置文件与脚本
    pamRemoteLogin
    pamSudo
    pamSshd
    pamSu
    sudoers
    entrypoint
  ]
  ++ extraContents;

  extraCommands = ''
    # 建立常规 usr/bin
    mkdir -p usr/bin
    ln -s ../bin usr/bin

    # 建立常规的 env 软链接
    ln -s ${coreutils}/bin/env usr/bin/env

    mkdir -m 1777 -p tmp
    mkdir -vp root
  '';

  config = {
    Cmd = [ "/entrypoint.sh" ];
    ExposedPorts = {
      "22/tcp" = { };
    };
    Env = [
      "ENV=/etc/profile.d/nix.sh"
      "BASH_ENV=/etc/profile.d/nix.sh"
      "NIX_BUILD_SHELL=/bin/bash"
      "NIX_PATH=nixpkgs=${./fake_nixpkgs}"
      "PAGER=cat"
      "PATH=/usr/bin:/bin"
      "SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt"
      "USER=root"
      "NIX_CONFIG=experimental-features = nix-command flakes"
    ]
    ++ extraEnv;
  };
}
