# modules/desktop.nix
{
  pkgs,
  lib,
  # clashPkgs,
  ...
}:

{
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
      wqy_zenhei
      wqy_microhei
      material-design-icons
      material-icons
      lxgw-wenkai
      # noto-fonts
      noto-fonts-color-emoji
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      nerd-fonts.comic-shanns-mono
      nerd-fonts.inconsolata
      # nerd-fonts.noto
      nerd-fonts.dejavu-sans-mono
      nerd-fonts.mononoki
    ]; # ++ builtins.filter lib.isDerivation (builtins.attrValues pkgs.nerd-fonts);
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
  environment.systemPackages =
    with pkgs;
    [
      brightnessctl # 屏幕亮度
      google-chrome # Google 浏览器
      (pkgs.symlinkJoin {
        name = "vscode-fhs-wrapped";
        paths = [ vscode-fhs ]; # 引用原始包
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          # 包装 bin 目录下的所有可执行文件
          # 对于 vscode-fhs，其二进制文件名通常是 code
          wrapProgram $out/bin/code \
            --add-flags "--password-store=gnome-libsecret"
        '';
      })
      sing-box # Sing-Box 客户端
      xray # XRay 客户端
      vlc # 媒体播放器
      telegram-desktop # Telegram 桌面版
      ayugram-desktop
      wireshark # 网络抓包工具
      wpsoffice-cn # WPS 中文版
      (pkgs.emacs-pgtk.overrideAttrs (old: {
        # --- 修正 1: 属性必须放在这里，确保 Nix 知道这台机器必须支持 v4 ---
        # requiredSystemFeatures = [ "gccarch-x86-64-native" ];

        # --- 修正 2: 环境变量注入 ---
        env = (old.env or { }) // {
          # 强制注入 NIX_CFLAGS_COMPILE，确保 C 代码和 Lisp 编译后端都吃到优化
          NIX_CFLAGS_COMPILE =
            (old.env.NIX_CFLAGS_COMPILE or "")
            + " -O3 -march=x86-64-v4 -fomit-frame-pointer -fno-semantic-interposition";
        };

        # --- 修正 3: 显式传递给 Configure ---
        # 这样 system-configuration-options 里就会留下证据
        preConfigure = (old.preConfigure or "") + ''
          export CFLAGS="-O3 -march=x86-64-v4 -fomit-frame-pointer"
          export CXXFLAGS="$CFLAGS"
          export LDFLAGS="-O3 -march=x86-64-v4 -flto=auto -Wl,-O1 -Wl,--as-needed"
        '';

        # --- 修正 4: 确保构建系统开启全量 AOT ---
        # Emacs 30+ 建议通过 configureFlags 明确 AOT 行为
        configureFlags = (old.configureFlags or [ ]) ++ [
          "--with-native-compilation=aot"
        ];
        # makeFlags = (old.makeFlags or [ ]) ++ [];
      }))
      localsend # 局域网传文件工具
      xclip # 剪切板工具
      wl-clipboard # 剪贴板工具
      flameshot # 截图工具
      xournalpp # 手写笔记软件
      nautilus # GNOME 文件管理器
      loupe # 图片查看器

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
    ]
    ++ [
      # 👇 单独放外面，就能正常用 clashPkgs
      clash-verge-rev
    ];
  # 这一行是关键！没有它，即便你在组里也抓不了包
  programs.wireshark.enable = true;
  programs.zsh.enable = true;
  programs.clash-verge = {
    enable = true;
    package = pkgs.clash-verge-rev; # 👈 强制用你修复的版本
    tunMode = true;
    serviceMode = true;
  };
  # 3. 确保 Polkit 服务运行
  security.polkit.enable = true;
  # 4. Xwayland 支持
  programs.xwayland.enable = true;
  programs.niri.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  services.ananicy = {
    enable = true;
    package = pkgs.ananicy-cpp;
    rulesProvider = pkgs.ananicy-rules-cachyos;
    extraRules = [
      {
        name = "niri";
        nice = -15;
        ioclass = "best-effort";
        ioprio = 0;
      }
      {
        name = "dms";
        nice = -10;
      }
      {
        name = "cc1";
        nice = 19;
      } # 顺便把编译器打入“冷宫”
      {
        name = "cc1plus";
        nice = 19;
      }
      {
        name = "go";
        nice = 19;
      }
      {
        name = "rustc";
        nice = 19;
      }
    ];
  };
  systemd.user.services."niri" = {
    serviceConfig = {
      TimeoutStopSec = "10s"; # 只要卡住超过 10 秒就直接强杀
    };
  };
}
