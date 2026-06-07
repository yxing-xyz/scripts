{
  config,
  pkgs,
  projectRoot,
  ...
}:

{
  home.file.".gtkrc-2.0".source =
    config.lib.file.mkOutOfStoreSymlink "${projectRoot}/home/.gtkrc-2.0";

  home.file.".icons/default/index.theme".source =
    config.lib.file.mkOutOfStoreSymlink "${projectRoot}/home/.icons/default/index.theme";

  xdg.configFile."gtk-3.0/settings.ini".source = config.lib.file.mkOutOfStoreSymlink "${projectRoot}/home/.config/gtk-3.0/settings.ini";
  xdg.configFile."gtk-4.0/settings.ini".source = config.lib.file.mkOutOfStoreSymlink "${projectRoot}/home/.config/gtk-4.0/settings.ini";
  xdg.configFile."xsettingsd".source = config.lib.file.mkOutOfStoreSymlink "${projectRoot}/home/.config/xsettingsd";

}
