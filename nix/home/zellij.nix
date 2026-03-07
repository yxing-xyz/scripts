{
  config,
  pkgs,
  projectRoot,
  ...
}:

{
  home.packages = [ pkgs.zellij ];
  xdg.configFile."zellij/config.kdl".source =
    config.lib.file.mkOutOfStoreSymlink "${projectRoot}/home/.config/zellij/config.kdl";
}
