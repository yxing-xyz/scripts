# 1. 默认值参数必须写在最顶层的函数入参声明里
{ pkgs
, extraContents ? [ ]
, extraEnv ? [ ]
}:
let
  # 2. 从 pkgs 继承时，变量用纯空格分隔，绝对不能加逗号
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
    xz;

  image = dockerTools.buildImageWithNixDb {
    inherit (nix) name;

    contents = [
      ./root
      coreutils
      # add /bin/sh
      bashInteractive
      nix

      # runtime dependencies of nix
      cacert
      git
      gnutar
      gzip
      openssh
      xz
      curl

      # for haskell binaries
      iana-etc
    ] ++ extraContents;

    extraCommands = ''
      # for /usr/bin/env
      mkdir -p usr
      ln -s ../bin usr/bin

      # make sure /tmp exists
      mkdir -m 1777 -p tmp

      # need a HOME
      mkdir -vp root
    '';

    config = {
      Cmd = [ "/bin/bash" ];
      Env = [
        "ENV=/etc/profile.d/nix.sh"
        "BASH_ENV=/etc/profile.d/nix.sh"
        "NIX_BUILD_SHELL=/bin/bash"
        "NIX_PATH=nixpkgs=${./fake_nixpkgs}"
        "PAGER=cat"
        "PATH=/usr/bin:/bin"
        "SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt"
        "USER=root"
      ] ++ extraEnv;
    };
  };
in
image // { meta = nix.meta // image.meta; }
