# home.nix
{ pkgs, niri, ... }:
{
  imports = [
    ./home/config.nix
    ./home/dev.nix
    ./home/gnome.nix
    ./home/niri.nix
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
    bat
    lsd
    fzf
    zoxide
    fd
    trash-cli
    sshuttle
    yazi
    tealdeer
    (pkgs.callPackage ./package/trzsz.nix { })
  ];
}
