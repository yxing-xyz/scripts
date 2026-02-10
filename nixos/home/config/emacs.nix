{
  config,
  pkgs,
  myScriptsPath,
  ...
}:

{
  home.file.".config/emacs".source =
    config.lib.file.mkOutOfStoreSymlink "${myScriptsPath}/home/.config/emacs";
}
