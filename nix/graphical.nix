{
  inputs,
  pkgs,
  lib,
  config,
  system,
  ...
}:

let
  # 定义一个辅助函数，简化 systemPackages 的管理
  inherit (lib) mkIf mkForce;
  clashPkgs = import inputs.clash-verge {
    inherit system;
  };
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
      package = clashPkgs.clash-verge-rev;
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


environment.systemPackages = with pkgs; [
    # ================= 基础工具 & 辅助 =================
    brightnessctl                                                   # 屏幕亮度控制工具
    xclip                                                           # X11 剪贴板命令行工具
    wl-clipboard                                                    # Wayland 剪贴板命令行工具 (wl-copy / wl-paste)
    nwg-look                                                        # Wayland 下的 GTK 外观配置图形界面工具

    # ================= 主题 & 图标 & 鼠标指针 =================
    gtk-engine-murrine                                              # 许多经典 GTK2 主题依赖的 Murrine 渲染引擎
    gtk_engines                                                     # GTK2 基础主题引擎集合
    adwaita-icon-theme                                              # GNOME 官方默认图标主题 (提供基础系统图标回退)
    bibata-cursors                                                  # 简约风现代鼠标指针主题
    tokyonight-gtk-theme                                           # Tokyo Night 暗色调 GTK 主题
    sweet                                                           # Sweet 炫彩霓罗/暗黑风格 GTK 主题
    sweet-folders                                                   # 适配 Sweet 主题的彩色文件夹图标
    flat-remix-gtk                                                  # Flat Remix 扁平风格 GTK 主题
    flat-remix-icon-theme                                           # Flat Remix 扁平图标主题

    # ================= Niri 桌面环境 & 窗口组件 =================
    niri                                                            # 可滚动平铺式 Wayland 窗口管理器 (Compositor)
    xwayland-satellite                                              # 为 Niri 提供无缝 XWayland 兼容支持的 X11 桥接服务
    fuzzel                                                          # 专为 Wayland 设计的高效轻量级应用启动器 / 菜单
    quickshell                                                      # 基于 QML 的高度可定制 Wayland 桌面组件/Bar 框架
    inputs.dms.packages.${pkgs.stdenv.hostPlatform.system}.default  # 从 Flake 输入引用的外部组件/软件包 (如 DMS 模块)
    cava                                                            # 控制台实时音频频谱可视化工具
    matugen                                                         # 基于 Wallpaper 自动提取颜色并生成 Material You 配色的工具

    # ================= 截图与图像标注 =================
    grim                                                            # Wayland 原生屏幕截图命令行工具
    slurp                                                           # Wayland 屏幕区域/窗口选择工具 (配合 grim 使用)
    swappy                                                          # 截图预览、剪裁与标注工具
  ];
}
