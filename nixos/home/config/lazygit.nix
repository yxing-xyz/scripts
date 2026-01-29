{config, pkgs, myScriptsPath, ... }:

{
  xdg.configFile."lazygit/config.yml".source = config.lib.file.mkOutOfStoreSymlink "${myScriptsPath}/home/.config/lazygit/config.yml";
}
