# home.nix
{ inputs, pkgs, ... }:
{
  imports = [
    ./options.nix
    ./home/zellij.nix
    ./home/fastfetch.nix
    ./home/lazygit.nix
    ./home/git.nix
    ./home/ssh.nix
    ./home/zsh.nix
    ./home/gtk.nix
    ./home/autostart.nix
    ./home/emacs.nix
    ./home/develop.nix
  ];
  home.sessionVariables = {
    # 基础 Wayland 支持
    NIXOS_OZONE_WL = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";

    # 针对虚拟机或特定 GPU 的图形优化
    NIXOS_OZONE_GFX_BURST = "1";

    # 如果你用的是 Niri/Noctalia，建议额外增加这两行解决 Java 应用(如 DBeaver)的显示问题
    _JAVA_AWT_WM_NONREPARENTING = "1";
    ANKI_WAYLAND = "1";
  };

  home.sessionVariables = {
    EDITOR = "vim";
    LANG = "zh_CN.UTF-8";
    LC_CTYPE = "zh_CN.UTF-8";
    COLORTERM = "truecolor";
  };

  home.packages = with pkgs; [
    gawk
    gnugrep
    gnused
    coreutils
    findutils
    procps
    nvd
    vim
    git
    lazygit
    lazydocker
    git-lfs
    curl
    unzip
    p7zip
    fastfetch
    htop
    docker-client
    skopeo
    difftastic
    umoci
    qemu
    nixfmt
    nix-tree
    lsof
    file
    aria2
    efibootmgr
    pciutils
    usbutils
    rsync
    jq
    dig
    iputils
    iproute2
    dnslookup
    dhcpcd
    ripgrep
    python3
    sing-box
    xray
    # zsh依赖
    bat
    lsd
    fzf
    zoxide
    fd
    trash-cli
    sshuttle
    yazi
    tealdeer
    direnv
    (pkgs.callPackage ./pkgs/trzsz { })
    inputs.home-manager.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
