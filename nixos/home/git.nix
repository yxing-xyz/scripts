{
  config,
  pkgs,
  projectRoot,
  ...
}:

{
  home.file.".gitconfig".source =
    config.lib.file.mkOutOfStoreSymlink "${projectRoot}/home/.gitconfig";

  home.file.".gitconfig".force = true;
}
