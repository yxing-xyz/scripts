# home.nix
{ pkgs, ... }:
{
  imports = [
    ./home/config.nix
    ./home/zsh.nix
    ./home/fish.nix
    ./home/dev.nix
    ./home/gnome.nix
  ];

  home.sessionVariables = {
    # 告诉 Electron 和 Chrome 使用 Wayland 渲染
    NIXOS_OZONE_GFX_BURST = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
  };

  home.sessionVariables = {
    RUSTUP_UPDATE_ROOT = "https://mirrors.aliyun.com/rustup/rustup";
    RUSTUP_DIST_SERVER = "https://mirrors.aliyun.com/rustup";
    GO111MODULE = "auto";
    GOPROXY = "https://goproxy.cn,direct";
    VCPKG_ROOT = "$HOME/.local/share/vcpkg";

    EDITOR = "vim";
    LANG = "zh_CN.UTF-8";
    LC_CTYPE = "zh_CN.UTF-8";
    COLORTERM = "truecolor";
    TRZSZ_ENABLE = "trzsz";
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
    (pkgs.callPackage ./package/trzsz.nix { })
  ];
  programs.bat.enable = true;
  programs.lsd.enable = true;
  programs.zoxide.enable = true;
}
