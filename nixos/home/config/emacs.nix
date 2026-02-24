{
  config,
  pkgs,
  myScriptsPath,
  ...
}:

{
  home.packages = with pkgs; [
    enchant
    emacsPackages.jinx
    hunspell
    hunspellDicts.en_US
  ];
  home.file.".config/emacs".source =
    config.lib.file.mkOutOfStoreSymlink "${myScriptsPath}/home/.config/emacs";
}
