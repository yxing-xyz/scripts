{
  config,
  pkgs,
  myScriptsPath,
  ...
}:

{
  home.packages = [
    pkgs.zsh
    pkgs.oh-my-posh
  ];
  home.file.".zshrc".source = config.lib.file.mkOutOfStoreSymlink "${myScriptsPath}/home/.zshrc";
  home.file.".config/zsh".source =
    config.lib.file.mkOutOfStoreSymlink "${myScriptsPath}/home/.config/zsh";
}
