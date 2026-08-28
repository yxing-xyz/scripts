{ pkgs, lib, config, ... }:

let
  # 提取生成 dconf INI 格式文本的转换函数
  toDconfIni = lib.generators.toINI {
    mkKeyValue = key: value: "${key}=${toString (lib.hm.gvariant.mkValue value)}";
  };
in
{
  # -------------------------------------------------------------------------
  # 1. CI 专属 Patch：重写 activation 脚本，改用纯离线 compile，完全避开 DBus
  # -------------------------------------------------------------------------
  home.activation.dconfSettings = lib.mkForce (
      lib.hm.dag.entryAfter [ "installPackages" ] ''
        iniFile="${pkgs.writeText "hm-dconf.ini" (toDconfIni config.dconf.settings)}"
        dconfDir="$HOME/.config/dconf"
        keyfileDir="$dconfDir/db/user.d"
        targetFile="$keyfileDir/00-home-manager"

        # 创建目录
        $DRY_RUN_CMD mkdir -p "$keyfileDir"

        # 关键修复：先强行删除只读的旧文件，避免 cp 覆盖失败
        $DRY_RUN_CMD rm -f "$targetFile"

        # 写入 INI 文本 keyfile
        $DRY_RUN_CMD cp "$iniFile" "$targetFile"

        # 离线直接编译成 user 二进制数据库，全程无 DBus 依赖
        $DRY_RUN_CMD ${pkgs.dconf}/bin/dconf compile "$dconfDir/user" "$keyfileDir"
      ''
    );

  # -------------------------------------------------------------------------
  # 2. 你的原版 dconf 配置保持原封不动
  # -------------------------------------------------------------------------
  dconf.settings = {
    "org/gnome/mutter" = {
      experimental-features = [ "scale-monitor-framebuffer" ];
      dynamic-workspaces = false;
      overlay-key = ""; # 禁止super概览
    };

    "org/gnome/desktop/interface" = {
      font-name = "Noto Sans CJK SC 10";
      document-font-name = "Noto Sans CJK SC 10";
      monospace-font-name = "Noto Sans Mono CJK SC 10";

      accent-color = "green";
      color-scheme = "prefer-dark";
      cursor-size = 24;
      cursor-theme = "Bibata-Modern-Ice";
      gtk-theme = "Sweet-v40";
      icon-theme = "Flat-Remix-Cyan-Dark";

      enable-hot-corners = false;
      show-battery-percentage = true;
      font-hinting = "none";
      font-antialiasing = "grayscale";
    };

    "org/gnome/shell/extensions/user-theme" = {
      name = "adwaita";
    };

    "org/gnome/desktop/session" = {
      idle-delay = 600;
    };

    "org/gnome/desktop/screensaver" = {
      lock-enabled = true;
      lock-delay = 0;
    };

    "org/gnome/settings-daemon/plugins/power" = {
      idle-dim = true;
      sleep-inactive-battery-timeout = 3600;
      sleep-inactive-battery-type = "suspend";
      sleep-inactive-ac-timeout = 3600;
      sleep-inactive-ac-type = "suspend";
      power-button-action = "nothing";
    };

    "org/gnome/desktop/peripherals/mouse" = {
      accel-profile = "flat";
      speed = 0.0;
    };

    "org/gnome/desktop/peripherals/touchpad" = {
      accel-profile = "flat";
      send-events = "disabled-on-external-mouse";
      two-finger-scrolling-enabled = true;
    };

    "org/gnome/desktop/search-providers" = {
      disable-external = true;
    };

    "org/gnome/shell/app-switcher" = {
      current-workspace-only = true;
    };

    "org/gnome/desktop/wm/keybindings" = {
      close = [ "<Super>q" ];
      toggle-fullscreen = [ "<Super>f" ];
      toggle-maximized = [ "<Super>m" ];
      show-desktop = [ "<Super>d" ];

      switch-to-workspace-1 = [ "<Super>1" ];
      switch-to-workspace-2 = [ "<Super>2" ];
      switch-to-workspace-3 = [ "<Super>3" ];
      switch-to-workspace-4 = [ "<Super>4" ];
      switch-to-workspace-5 = [ "<Super>5" ];
      switch-to-workspace-left = [ "<Super>Left" ];
      switch-to-workspace-right = [ "<Super>Right" ];

      move-to-workspace-1 = [ "<Shift><Super>1" ];
      move-to-workspace-2 = [ "<Shift><Super>2" ];
      move-to-workspace-3 = [ "<Shift><Super>3" ];
      move-to-workspace-4 = [ "<Shift><Super>4" ];
      move-to-workspace-5 = [ "<Shift><Super>5" ];
      move-to-workspace-left = [ "<Shift><Super>Left" ];
      move-to-workspace-right = [ "<Shift><Super>Right" ];

      switch-applications = [ "<Alt>Tab" ];
      switch-applications-backward = [ "<Shift><Alt>Tab" ];
      lock-screen = [ "<Super><Control>l" ];

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

    "org/gnome/desktop/wm/preferences" = {
      mouse-button-modifier = "<Super>";
      num-workspaces = 5;
    };

    "org/gnome/desktop/sound" = {
      event-sounds = false;
    };

    "org/gnome/shell/keybindings" = {
      focus-active-notification = [ ];
      screenshot = [ ];
      screenshot-window = [ ];
      show-screenshot-ui = [ "Print" ];
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

      toggle-application-view = [ "<Super>r" ];
      toggle-overview = [ "<Super>Tab" ];
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      binding = "<Super>t";
      command = "curl '127.0.0.1:60828/selection_translate'";
      name = "翻译";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
      binding = "Print";
      command = "gnome-screenshot --interactive";
      name = "GNOME 交互截图";
    };

    "org/gnome/settings-daemon/plugins/media-keys" = {
      home = [ "<Super>e" ];
      screensaver = [ "<Super><Control>l" ];
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
      ];
    };

    "org/gnome/desktop/input-sources" = {
      sources = [
        (lib.hm.gvariant.mkTuple [
          "xkb"
          "my-pc105"
        ])
      ];
      mru-sources = [
        (lib.hm.gvariant.mkTuple [
          "xkb"
          "us"
        ])
      ];
      show-all-sources = true;
      xkb-options = [ "terminate:ctrl_alt_bksp" ];
    };

    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = [
        "clipboard-indicator@tudmotu.com"
        "gnome-shell-go-to-last-workspace@github.com"
        "kimpanel@kde.org"
        "user-theme@gnome-shell-extensions.gcampax.github.com"
        "Vitals@CoreCoding.com"
        "launch-new-instance@gnome-shell-extensions.gcampax.github.com"
        "light-style@gnome-shell-extensions.gcampax.github.com"
        "drive-menu@gnome-shell-extensions.gcampax.github.com"
        "appindicatorsupport@rgcjonas.gmail.com"
      ];

      disabled-extensions = [
        "auto-move-windows@gnome-shell-extensions.gcampax.github.com"
        "apps-menu@gnome-shell-extensions.gcampax.github.com"
        "native-window-placement@gnome-shell-extensions.gcampax.github.com"
        "places-menu@gnome-shell-extensions.gcampax.github.com"
        "screenshot-window-sizer@gnome-shell-extensions.gcampax.github.com"
        "status-icons@gnome-shell-extensions.gcampax.github.com"
        "system-monitor@gnome-shell-extensions.gcampax.github.com"
        "window-list@gnome-shell-extensions.gcampax.github.com"
        "windowsNavigator@gnome-shell-extensions.gcampax.github.com"
        "workspace-indicator@gnome-shell-extensions.gcampax.github.com"
      ];
    };

    "org/gnome/shell/extensions/vitals" = {
      fixed-widths = false;
      hide-icons = false;
      hide-zeros = false;
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
      "clear-history" = [ ];
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
}
