{config, pkgs, myScriptsPath, ... }:


{
  home.packages = [ pkgs.zsh ];
  home.file.".zshrc".source = config.lib.file.mkOutOfStoreSymlink "${myScriptsPath}/home/.zshrc";
}
