{
  inputs,
  pkgs,
  lib,
  config,
  ...
}:

let
  # 定义一个辅助函数，简化 systemPackages 的管理
  inherit (lib) mkIf mkForce;
in
{
  # --- 1. 服务与显示设置 ---
  services.xserver = {
    enable = true;
    exportConfiguration = mkForce true;
    xkb = {
      layout = "my-pc105";
      extraLayouts.my-pc105 = {
        description = "My Keyboard Layout";
        languages = [ "eng" ];
        symbolsFile = pkgs.writeText "pc105_custom" ''
          default partial alphanumeric_keys modifier_keys
          xkb_symbols "pc105" {
              include "us"
              replace key <CAPS> { [ Control_L ] };
              modifier_map Control { <CAPS> };
              replace key <RALT> { [ Caps_Lock ] };
              modifier_map Lock { <RALT> };
          };
        '';
      };
    };
  };

  # --- 2. 国际化与输入法 ---
  i18n = {
    defaultLocale = "zh_CN.UTF-8";
    inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5 = {
        waylandFrontend = true;
        addons = with pkgs; [
          fcitx5-rime
          rime-data
          rime-ice
          fcitx5-gtk
          fcitx5-mellow-themes
          qt6Packages.fcitx5-chinese-addons
          qt6Packages.fcitx5-configtool
        ];
      };
    };
  };

  # --- 3. 字体配置 (简化版) ---
  fonts = {
    enableDefaultPackages = false;
    packages = with pkgs; [
      lxgw-wenkai
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji
      nerd-fonts.comic-shanns-mono
      nerd-fonts.inconsolata
      nerd-fonts.dejavu-sans-mono
      nerd-fonts.mononoki
    ];
    fontconfig = {
      enable = true;
      defaultFonts = {
        sansSerif = [ "Noto Sans CJK SC" ];
        serif = [ "Noto Serif CJK SC" ];
        monospace = [ "Noto Sans Mono CJK SC" ];
      };
    };
  };

  # --- 4. 程序启用与配置 ---
  programs = {
    niri.enable = true;
    xwayland.enable = true;
    wireshark.enable = true;
    zsh.enable = true;
    clash-verge = {
      enable = true;
      package = pkgs.clash-verge-rev;
      tunMode = true;
      serviceMode = true;
    };
  };
  nixpkgs.config.permittedInsecurePackages = [
    "pnpm-9.15.9"
  ];

  # --- 6. 系统底层与性能调度 ---
  services = {
    flatpak.enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
    ananicy = {
      enable = true;
      package = pkgs.ananicy-cpp;
      rulesProvider = pkgs.ananicy-rules-cachyos;
    };
    gnome.gnome-keyring.enable = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.fcitx5-gtk
      pkgs.xdg-desktop-portal-gnome
      pkgs.xdg-desktop-portal-gtk
    ];
    config.common.default = [ "gtk" ];
  };

  # --- 7. 系统级微调 ---
  security.polkit.enable = true;
  systemd.user.services."niri".serviceConfig.TimeoutStopSec = "10s";

  # --- 5. 软件包定义 ---
  environment.systemPackages = with pkgs; [
    # 基础工具
    brightnessctl
    xclip
    wl-clipboard
    nwg-look
    # 主题/引擎
    gtk-engine-murrine
    gtk_engines
    adwaita-icon-theme
    bibata-cursors
    tokyonight-gtk-theme
    sweet
    sweet-folders
    flat-remix-gtk
    flat-remix-icon-theme
    # Niri 相关
    niri
    xwayland-satellite
    fuzzel
    quickshell
    inputs.dms.packages.${pkgs.stdenv.hostPlatform.system}.default
    cava
    matugen
    # 截图
    grim
    slurp
    swappy
  ];
}
