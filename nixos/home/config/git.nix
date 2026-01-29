{
  config,
  pkgs,
  myScriptsPath,
  ...
}:

{
  home.file.".gitconfig".source =
    config.lib.file.mkOutOfStoreSymlink "${myScriptsPath}/home/.gitconfig";
}
