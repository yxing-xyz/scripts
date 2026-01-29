# modules/desktop.nix
{
  pkgs,
  lib,
  pot-fixed,
  nixpkgs-unstable,
  ...
}:

{
  users.users.x = {
    isNormalUser = true;
    description = "x";
    extraGroups = [
      "networkmanager"
      "wheel"
      "video"
      "wireshark"
      "docker"
    ]; # wheel 组提供 sudo 权限
    initialPassword = "x";
    shell = pkgs.zsh;
    # 必须保证 UID 和旧系统一致，通常是 1000
    uid = 1000;
  };
  # 1. 核心 GUI 服务（如果你用 GNOME）
  console.useXkbConfig = false;
  # 放在这里最合理
  services.xserver = {
    enable = true;
    exportConfiguration = lib.mkForce true;
    xkb = {
      layout = "my-pc105";
      extraLayouts.my-pc105 = {
        description = "My Keyboard Layout";
        languages = [ "eng" ];
        # 关键点：直接把你的代码块写成字符串
        symbolsFile = pkgs.writeText "pc105_custom" ''
          default partial alphanumeric_keys modifier_keys
          xkb_symbols "pc105" {
              include "us" # 继承标准的美国布局

              replace key <CAPS> { [ Control_L ] };
              modifier_map Control { <CAPS> };
              replace key <RALT> { [ Caps_Lock ] };
              modifier_map Lock { <RALT> };
          };
        '';
      };
    };
  };
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  programs.niri.enable = true;
  # services.displayManager.sessionPackages = [ pkgs.niri ];
  # 国际化配置
  i18n.defaultLocale = "zh_CN.UTF-8";
  # 额外的本地化设置（可选，建议保持一致）
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "zh_CN.UTF-8";
    LC_IDENTIFICATION = "zh_CN.UTF-8";
    LC_MEASUREMENT = "zh_CN.UTF-8";
    LC_MONETARY = "zh_CN.UTF-8";
    LC_NAME = "zh_CN.UTF-8";
    LC_NUMERIC = "zh_CN.UTF-8";
    LC_PAPER = "zh_CN.UTF-8";
    LC_TELEPHONE = "zh_CN.UTF-8";
    LC_TIME = "zh_CN.UTF-8";
  };

  # 确保已经安装了 fcitx5 和 rime
  i18n.inputMethod = {
    enable = true; # 新的开启方式
    # 2. 明确指定输入法框架类型
    type = "fcitx5";
    fcitx5.waylandFrontend = true;
    fcitx5.addons = with pkgs; [
      fcitx5-rime
      rime-data
      rime-ice
      # 改为下面这样，明确指向 qt6Packages
      qt6Packages.fcitx5-chinese-addons
      fcitx5-gtk
      # 同样的，配置工具也建议用这个，兼容性更好
      qt6Packages.fcitx5-configtool
      fcitx5-mellow-themes
    ];
  };
  # 建议配置环境变量，确保应用能正确识别
  environment.variables = {
    XMODIFIERS = lib.mkForce "@im=fcitx5";
  };

  fonts = {
    fontDir.enable = true;
    packages = with pkgs; [
      material-design-icons
      material-icons
      lxgw-wenkai
      noto-fonts
      noto-fonts-color-emoji
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      nerd-fonts.mononoki
      nerd-fonts.inconsolata
      nerd-fonts.dejavu-sans-mono
      nerd-fonts.code-new-roman
      nerd-fonts.noto
    ];
    fontconfig = {
      enable = true;
      defaultFonts = {
        # 界面、网页默认字体
        sansSerif = [ "Noto Sans CJK SC" ];
        # 衬线字体（宋体类）
        serif = [ "Noto Serif CJK SC" ];
        # 终端、代码字体
        monospace = [ "Noto Sans Mono CJK SC" ];
      };
    };
  };

  services.flatpak.enable = true;
  xdg.portal = {
    enable = true;
    # 关键点：根据不同桌面环境加载对应的 Portal
    extraPortals = [
      pkgs.xdg-desktop-portal-gnome # 支持 GNOME 特色功能（壁纸、设置等）
      pkgs.xdg-desktop-portal-gtk # 通用 fallback，微信/钉钉这类应用最吃这一套
    ];

    config = {
      # 全局默认使用 gtk
      common.default = [ "gtk" ];

      # 针对 Niri 的特定配置 (Niri 官方建议使用 gnome 或 wlr)
      niri = {
        default = [
          "gnome"
          "gtk"
        ];
        # 屏幕共享必须使用 gnome 或 wlr 接口
        "org.freedesktop.impl.portal.ScreenCast" = [ "gnome" ];
        "org.freedesktop.impl.portal.Screenshot" = [ "gnome" ];
      };

      # 针对 GNOME 的特定配置
      gnome = {
        default = [ "gnome" ];
      };
    };
  };
  # 3. 基础 GUI 软件包
  environment.systemPackages = with pkgs; [
    brightnessctl # 屏幕亮度
    google-chrome # Google 浏览器
    (nixpkgs-unstable.vscode.override {
      commandLineArgs = [
        "--password-store=gnome-libsecret"
        "--ozone-platform-hint=auto" # 顺便强制开启原生 Wayland 支持，告别模糊
        "--enable-features=WaylandWindowDecorations"
      ];
    })
    v2rayn # V2RayN 客户端
    sing-box # Sing-Box 客户端
    xray # XRay 客户端
    vlc # 媒体播放器
    telegram-desktop # Telegram 桌面版
    wireshark # 网络抓包工具
    wpsoffice-cn # WPS 中文版
    emacs-pgtk # 图形版 Emacs
    localsend # 局域网传文件工具
    xclip # 剪切板工具
    wl-clipboard # 剪贴板工具
    pot-fixed # 划词翻译
    flameshot # 截图工具
    xournalpp # 手写笔记软件
    nautilus # GNOME 文件管理器

    ## theme
    nwg-look
    gtk-engine-murrine # 负责渐变和圆角
    gtk_engines # 包含 Pixmap 等基础引擎
    adwaita-icon-theme # 很多主题依赖的基础图标库
    bibata-cursors

    tokyonight-gtk-theme
    sweet
    sweet-folders
    flat-remix-gtk
    flat-remix-icon-theme
    ## niri
    niri
    xwayland-satellite
    fuzzel
  ];
  # 这一行是关键！没有它，即便你在组里也抓不了包
  programs.wireshark.enable = true;
  programs.zsh.enable = true;

  # 3. 确保 Polkit 服务运行
  security.polkit.enable = true;
  # 4. Xwayland 支持
  programs.xwayland.enable = true;
}
