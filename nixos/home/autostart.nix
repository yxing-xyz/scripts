{
  config,
  pkgs,
  myScriptsPath,
  ...
}:

{
  home.file.".config/autostart".source =
    config.lib.file.mkOutOfStoreSymlink "${myScriptsPath}/home/.config/autostart";
}
