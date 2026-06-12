{
  config,
  pkgs,
  projectRoot,
  ...
}:

{
  xdg.configFile."lazygit/config.yml".source =
    config.lib.file.mkOutOfStoreSymlink "${projectRoot}/home/.config/lazygit/config.yml";
}
