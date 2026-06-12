{
  config,
  pkgs,
  dms,
  projectRoot,
  ...
}:

{
  xdg.configFile."niri".source =
    config.lib.file.mkOutOfStoreSymlink "${projectRoot}/home/.config/niri";

  xdg.configFile."DankMaterialShell".source =
    config.lib.file.mkOutOfStoreSymlink "${projectRoot}/home/.config/DankMaterialShell";
}
