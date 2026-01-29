# modules/desktop.nix
{
  pkgs,
  lib,
  pot-fixed,
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
  i18n.inputMethod = {
    # 以前是 enabled = "fcitx5";
    # 现在拆分为两行：
    enable = true;
    type = "fcitx5";

    # 下面这一块保持不变
    fcitx5.addons = with pkgs; [
      fcitx5-rime
      # 改为下面这样，明确指向 qt6Packages
      qt6Packages.fcitx5-chinese-addons
      fcitx5-gtk
      # 同样的，配置工具也建议用这个，兼容性更好
      qt6Packages.fcitx5-configtool
      rime-ice
    ];
  };
  # 建议配置环境变量，确保应用能正确识别
  environment.variables = {
    GTK_IM_MODULE = lib.mkForce "fcitx5";
    QT_IM_MODULE = lib.mkForce "fcitx5";
    XMODIFIERS = lib.mkForce "@im=fcitx5";
    SDL_IM_MODULE = lib.mkForce "fcitx5";
  };

  fonts = {
    fontDir.enable = true;
    packages = with pkgs; [
      material-design-icons
      material-icons
      lxgw-wenkai
      noto-fonts
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

  # 3. 基础 GUI 软件包
  environment.systemPackages = with pkgs; [
    google-chrome # Google 浏览器
    vscode # Visual Studio Code
    v2rayn # V2RayN 客户端
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
  ];
}
