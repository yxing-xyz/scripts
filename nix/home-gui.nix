{ config, pkgs, ... }:
{
  imports = [
    ./options.nix
  ];
home.packages = with pkgs; [
    # ================= 开发工具 & 编辑器 =================
    (pkgs.symlinkJoin {
      name = "vscode-fhs-wrapped";
      paths = [ vscode-fhs ];                                         # VS Code FHS 兼容环境（方便插件使用系统动态库）
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/code --add-flags "--password-store=gnome-libsecret"  # 包装启动参数：强制使用 GNOME Secret 存储凭据/密码
      '';
    })
    alacritty                                                         # 跨平台 GPU 加速终端模拟器
    emacs-pgtk                                                        # 原生支持 Wayland (Pure GTK) 的 Emacs 编辑器

    # ================= 媒体 & 实用工具 =================
    zenity                                                            # 命令行图形对话框工具 (NixOS/脚本常用依赖)
    vlc                                                               # 经典全能全格式媒体播放器
    wireshark                                                         # 网络数据包分析工具 / 抓包神器
    localsend                                                         # 跨平台局域网文件传输工具 (AirDrop 替代品)
    nautilus                                                          # GNOME 官方文件管理器 (Files)
    loupe                                                             # GNOME 官方现代图片查看器

    # ================= 办公与通讯 =================
    google-chrome                                                     # Google Chrome 浏览器
    telegram-desktop                                                  # Telegram 官方桌面客户端
    ayugram-desktop                                                   # 带有高级自定义特性的 Telegram 第三方客户端
    wpsoffice-cn                                                      # WPS Office 中文版 (含文字、表格、演示等)
    xournalpp                                                         # 手写笔记与 PDF 标注手绘软件

    # ================= 输入法引擎 =================
    librime                                                           # RIME (中州韵/小狼毫/鼠须管) 中文输入法核心引擎库

    # ================= GNOME 基础设置与扩展管理 =================
    gnome-tweaks                                                      # GNOME 优化工具 (高级系统参数与主题配置)
    gnome-extension-manager                                           # 第三方 GNOME 扩展管理器 (带有浏览和在线安装界面)
    gnome-shell-extensions                                            # GNOME 官方维护的基础扩展包集合

    # ================= GNOME Shell 桌面扩展 =================
    gnomeExtensions.clipboard-indicator                            # 剪贴板历史记录面板扩展
    gnomeExtensions.go-to-last-workspace                           # 快速切换/返回上一个工作区的扩展
    gnomeExtensions.kimpanel                                       # 提供对 Fcitx5/RIME 等输入法候选框面板支持的扩展
    # gnomeExtensions.user-themes                                  # 用户自定义 Shell 主题扩展 (已注释)
    gnomeExtensions.vitals                                         # 顶栏实时硬件监控扩展 (CPU、内存、温度、网速)
    gnomeExtensions.appindicator                                   # 托盘图标支持扩展 (让应用后台图标显示在顶栏)
    flat-remix-gnome                                               # Flat Remix 风格的 GNOME Shell 主题包
  ];
}
