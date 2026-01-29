{ pkgs, ... }:

{
  imports = [
    ./alacritty.nix
    ./fcitx5.nix
    ./autostart.nix
  ];

  dconf.settings = {
    "org/gnome/mutter" = {
      experimental-features = [ "scale-monitor-framebuffer" ];
    };
    "org/gnome/desktop/interface" = {
      font-name = "Noto Sans CJK SC 10";
      document-font-name = "Noto Sans CJK SC 10";
      monospace-font-name = "Noto Sans Mono CJK SC 10";

      # 界面强调色设为紫色
      accent-color = "green";
      # 配色方案：'default' 对应自动（跟随系统），'prefer-dark' 是强制深色，'prefer-light' 是强制浅色
      color-scheme = "prefer-dark";
      # 恢复默认的 Adwaita 三件套
      cursor-size = 36;
      cursor-theme = "Bibata-Modern-Ice";
      gtk-theme = "Sweet-v40";
      icon-theme = "Flat-Remix-Cyan-Dark";

      # 关闭热区
      enable-hot-corners = false;
      # 显示电源百分比
      show-battery-percentage = true;
      # 高分辨率关闭字体抗锯齿和提示
      font-hinting = "none";
      # 高分辨率使用灰度就行
      font-antialiasing = "grayscale";
    };

    "org/gnome/shell/extensions/user-theme" = {
      name = "adwaita";
    };
    # 设置自动熄屏时间（10分钟）
    "org/gnome/desktop/session" = {
      idle-delay = 600; # 秒为单位，600s = 10min
    };
    # 锁定屏幕设置（可选）
    "org/gnome/desktop/screensaver" = {
      lock-enabled = true; # 熄屏后是否锁定
      lock-delay = 0; # 熄屏后多久锁定（0表示立即锁定）
    };
    "org/gnome/settings-daemon/plugins/power" = {
      # 休眠之前屏幕变暗
      idle-dim = true;
      # 自动休眠设置
      sleep-inactive-battery-timeout = 3600;
      sleep-inactive-battery-type = "suspend";
      sleep-inactive-ac-timeout = 3600;
      sleep-inactive-ac-type = "suspend";

      # 关键设置：按下电源键什么都不做
      power-button-action = "nothing";
    };

    # 关闭鼠标加速
    "org/gnome/desktop/peripherals/mouse" = {
      # 关键设置：将加速方案设为 'flat'，即关闭加速，实现 1:1 像素追踪
      accel-profile = "flat";
      # 你也可以在这里调节基础灵敏度（范围 -1.0 到 1.0，0 是默认）
      speed = 0.0;
    };
    "org/gnome/desktop/peripherals/touchpad" = {
      accel-profile = "flat"; # 关闭鼠标加速
      send-events = "disabled-on-external-mouse";
      two-finger-scrolling-enabled = true; # 双指滚动
    };
    "org/gnome/desktop/search-providers" = {
      disable-external = true;
    };
    "org/gnome/shell/app-switcher" = {
      current-workspace-only = true;
    };

    "org/gnome/desktop/wm/keybindings" = {
      # 基础窗口操作
      close = [ "<Super>q" ];
      toggle-fullscreen = [ "<Control><Super>f" ];
      toggle-maximized = [ "<Control><Super>m" ];
      show-desktop = [ "<Super>d" ];

      # 切换工作区 (1-5)
      switch-to-workspace-1 = [ "<Super>1" ];
      switch-to-workspace-2 = [ "<Super>2" ];
      switch-to-workspace-3 = [ "<Super>3" ];
      switch-to-workspace-4 = [ "<Super>4" ];
      switch-to-workspace-5 = [ "<Super>5" ];
      switch-to-workspace-left = [ "<Super>Left" ];
      switch-to-workspace-right = [ "<Super>Right" ];

      # 移动窗口到工作区
      move-to-workspace-1 = [ "<Shift><Super>1" ];
      move-to-workspace-2 = [ "<Shift><Super>2" ];
      move-to-workspace-3 = [ "<Shift><Super>3" ];
      move-to-workspace-4 = [ "<Shift><Super>4" ];
      move-to-workspace-5 = [ "<Shift><Super>5" ];
      move-to-workspace-left = [ "<Shift><Super>Left" ];
      move-to-workspace-right = [ "<Shift><Super>Right" ];

      # 应用切换
      switch-applications = [ "<Alt>Tab" ];
      switch-applications-backward = [ "<Shift><Alt>Tab" ];

      # 禁用大量默认快捷键 (设为空列表)
      activate-window-menu = [ ];
      begin-move = [ ];
      begin-resize = [ ];
      cycle-group = [ ];
      cycle-group-backward = [ ];
      cycle-panels = [ ];
      cycle-panels-backward = [ ];
      cycle-windows = [ ];
      cycle-windows-backward = [ ];
      maximize = [ ];
      minimize = [ ];
      move-to-monitor-down = [ ];
      move-to-monitor-left = [ ];
      move-to-monitor-right = [ ];
      move-to-monitor-up = [ ];
      move-to-workspace-last = [ ];
      panel-run-dialog = [ ];
      switch-group = [ ];
      switch-group-backward = [ ];
      switch-input-source = [ ];
      switch-input-source-backward = [ ];
      switch-panels = [ ];
      switch-panels-backward = [ ];
      switch-to-workspace-last = [ ];
      switch-windows = [ ];
      switch-windows-backward = [ ];
      unmaximize = [ ];
    };

    # 1. 禁用动态工作区（固定工作区数量的前提）
    "org/gnome/mutter" = {
      dynamic-workspaces = false;
      overlay-key = ""; # 禁止super概览
    };
    "org/gnome/desktop/wm/preferences" = {
      # 按住 Super 键可以用鼠标拖动窗口
      mouse-button-modifier = "<Super>";
      # 固定工作区数量为 5
      num-workspaces = 5;
    };

    "org/gnome/desktop/sound" = {
      event-sounds = false;
    };

    "org/gnome/shell/keybindings" = {
      # 禁用一系列默认快捷键
      focus-active-notification = [ ];
      screenshot = [ ];
      screenshot-window = [ ];
      show-screenshot-ui = [ ];
      switch-to-application-1 = [ ];
      switch-to-application-2 = [ ];
      switch-to-application-3 = [ ];
      switch-to-application-4 = [ ];
      switch-to-application-5 = [ ];
      switch-to-application-6 = [ ];
      switch-to-application-7 = [ ];
      switch-to-application-8 = [ ];
      switch-to-application-9 = [ ];
      toggle-message-tray = [ ];
      toggle-quick-settings = [ ];

      # 关键修改：设置 Super + R 打开应用菜单
      toggle-application-view = [ "<Super>r" ];
      # 将“概览”切换设置为 Super + Tab
      toggle-overview = [ "<Super>Tab" ];
    };

    # 1. 定义快捷键的具体内容
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      binding = "<Super>t";
      command = "curl '127.0.0.1:60828/selection_translate'";
      name = "翻译";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
      binding = "Print";
      # 注意：Nix 字符串中反斜杠和引号的处理
      command = "script --command \"QT_QPA_PLATFORM=wayland flameshot gui\" /dev/null";
      name = "截图";
    };

    # 2. 关键步骤：必须在这里注册上述路径，GNOME 才会读取它们
    "org/gnome/settings-daemon/plugins/media-keys" = {
      home = [ "<Super>e" ]; # 添加这一行，恢复 Super+E 打开主目录
      screensaver = [ "<Alt><Super>l" ];
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
      ];
    };
    "org/gnome/shell" = {
      disable-user-extensions = false;
      # 启用扩展列表 (这里的 ID 必须非常精准)
      enabled-extensions = [
        "clipboard-indicator@tudmotu.com" # 剪贴板指示器
        "gnome-shell-go-to-last-workspace@github.com" # 返回上个工作区
        "kimpanel@kde.org" # 输入法面板 (Fcitx 常用)
        "user-theme@gnome-shell-extensions.gcampax.github.com" # 用户主题支持
        "Vitals@CoreCoding.com" # Vitals 系统状态看板

        "launch-new-instance@gnome-shell-extensions.gcampax.github.com" # 点击图标强制打开新实例
        "light-style@gnome-shell-extensions.gcampax.github.com" # 浅色风格适配
        "drive-menu@gnome-shell-extensions.gcampax.github.com" # 挂载驱动器管理
        "appindicatorsupport@rgcjonas.gmail.com" # AppIndicator 托盘支持
      ];

      disabled-extensions = [
        "auto-move-windows@gnome-shell-extensions.gcampax.github.com" # 自动移动窗口
        "apps-menu@gnome-shell-extensions.gcampax.github.com" # 应用程序菜单 (经典)
        "native-window-placement@gnome-shell-extensions.gcampax.github.com" # 原生窗口排布
        "places-menu@gnome-shell-extensions.gcampax.github.com" # 位置菜单 (侧边栏)
        "screenshot-window-sizer@gnome-shell-extensions.gcampax.github.com" # 截图窗口尺寸调整
        "status-icons@gnome-shell-extensions.gcampax.github.com" # 状态图标
        "system-monitor@gnome-shell-extensions.gcampax.github.com" # 系统监视器
        "window-list@gnome-shell-extensions.gcampax.github.com" # 窗口列表 (类似任务栏)
        "windowsNavigator@gnome-shell-extensions.gcampax.github.com" # 窗口导航器
        "workspace-indicator@gnome-shell-extensions.gcampax.github.com" # 工作区指示器
      ];
    };

    "org/gnome/shell/extensions/vitals" = {
      fixed-widths = false;
      hide-icons = false;
      hide-zeros = false;
      # 这里的传感器 ID 必须与你导出的一致
      hot-sensors = [
        "_processor_usage_"
        "_memory_usage_"
        "_network-tx_wlp97s0_tx_"
        "_network-rx_wlp97s0_rx_"
      ];
      icon-style = 1;
      menu-centered = false;
      position-in-panel = 2;
      show-measurement = true;
      update-time = 2;
      use-higher-precision = false;
    };
    "org/gnome/shell/extensions/clipboard-indicator" = {
      "cache-size" = 100;
      "case-sensitive-search" = true;
      "clear-history" = [ ]; # Nix 中 @as [] 对应空列表
      "display-mode" = 0;
      "enable-keybindings" = true;
      "history-size" = 1000;
      "next-entry" = [ ];
      "notify-on-cycle" = false;
      "paste-button" = true;
      "paste-on-select" = true;
      "prev-entry" = [ ];
      "preview-size" = 50;
      "private-mode-binding" = [ ];
      "regex-search" = true;
      "synced-selection" = true;
      "toggle-menu" = [ "<Super>v" ];
    };
  };

  home.packages = with pkgs; [
    # 基础工具
    gnome-tweaks
    gnome-extension-manager
    gnome-shell-extensions
    # 扩展包
    gnomeExtensions.clipboard-indicator
    gnomeExtensions.go-to-last-workspace
    gnomeExtensions.kimpanel
    # gnomeExtensions.user-themes
    gnomeExtensions.vitals
    gnomeExtensions.appindicator
    flat-remix-gnome
  ];
}
