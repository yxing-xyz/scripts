{
  config,
  pkgs,
  myScriptsPath,
  ...
}:

{
  home.packages = [ pkgs.zellij ];
  xdg.configFile."zellij/config.kdl".source =
    config.lib.file.mkOutOfStoreSymlink "${myScriptsPath}/home/.config/zellij/config.kdl";
}
