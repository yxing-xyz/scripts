{
  config,
  pkgs,
  myScriptsPath,
  ...
}:

{
  home.file.".gtkrc-2.0".source =
    config.lib.file.mkOutOfStoreSymlink "${myScriptsPath}/home/.gtkrc-2.0";

  home.file.".icons/default/index.theme".source =
    config.lib.file.mkOutOfStoreSymlink "${myScriptsPath}/home/.icons/default/index.theme";

  xdg.configFile."gtk-3.0/settings.ini".source = config.lib.file.mkOutOfStoreSymlink "${myScriptsPath}/home/.config/gtk-3.0/settings.ini";
  xdg.configFile."gtk-4.0/settings.ini".source = config.lib.file.mkOutOfStoreSymlink "${myScriptsPath}/home/.config/gtk-4.0/settings.ini";
  xdg.configFile."xsettingsd".source = config.lib.file.mkOutOfStoreSymlink "${myScriptsPath}/home/.config/xsettingsd";

}
