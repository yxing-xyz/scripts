{
  config,
  pkgs,
  myScriptsPath,
  ...
}:

{
  # 这一行确保 alacritty 软件包已安装
  home.packages = [ pkgs.alacritty ];

  # 直接把字符串写入 ~/.config/alacritty/alacritty.toml
  xdg.configFile."alacritty/alacritty.toml".source = config.lib.file.mkOutOfStoreSymlink "${myScriptsPath}/home/.config/alacritty/alacritty.toml";
}
