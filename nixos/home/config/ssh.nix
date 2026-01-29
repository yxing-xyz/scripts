{
  config,
  pkgs,
  myScriptsPath,
  ...
}:

{
  home.file.".ssh".source =
    config.lib.file.mkOutOfStoreSymlink "${myScriptsPath}/home/.ssh";
}
