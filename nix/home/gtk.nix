{
  config,
  pkgs,
  projectRoot,
  ...
}:

{
  home.file.".gtkrc-2.0".source =
    config.lib.file.mkOutOfStoreSymlink "${projectRoot}/home/.gtkrc-2.0";
  home.file.".gtkrc-2.0".force = true;

  home.file.".icons/default/index.theme".source =
    config.lib.file.mkOutOfStoreSymlink "${projectRoot}/home/.icons/default/index.theme";
  home.file.".icons/default/index.theme".force = true;


  xdg.configFile."gtk-3.0/settings.ini".source =
    config.lib.file.mkOutOfStoreSymlink "${projectRoot}/home/.config/gtk-3.0/settings.ini";
  xdg.configFile."gtk-3.0/settings.ini".force = true;

  xdg.configFile."gtk-4.0/settings.ini".source =
    config.lib.file.mkOutOfStoreSymlink "${projectRoot}/home/.config/gtk-4.0/settings.ini";
  xdg.configFile."gtk-4.0/settings.ini".force = true;

  xdg.configFile."xsettingsd".source =
    config.lib.file.mkOutOfStoreSymlink "${projectRoot}/home/.config/xsettingsd";
  xdg.configFile."xsettingsd".force =true;


  xdg.configFile."code-flags.conf".source =
    config.lib.file.mkOutOfStoreSymlink "${projectRoot}/home/.config/code-flags.conf";
  xdg.configFile."code-flags.conf".force = true;
}
