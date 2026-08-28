{
  config,
  pkgs,
  projectRoot,
  ...
}:

{
  home.file.".config/autostart".source =
    config.lib.file.mkOutOfStoreSymlink "${projectRoot}/home/.config/autostart";
}
