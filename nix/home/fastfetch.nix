{
  config,
  pkgs,
  projectRoot,
  ...
}:

{
  # 这一行确保 alacritty 软件包已安装
  home.packages = [ pkgs.fastfetch ];

  xdg.configFile."fastfetch/config.jsonc".source =
    config.lib.file.mkOutOfStoreSymlink "${projectRoot}/home/.config/fastfetch/config.jsonc";
}
