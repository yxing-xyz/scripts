{
  config,
  pkgs,
  projectRoot,
  ...
}:

{
  home.file.".ssh".source = config.lib.file.mkOutOfStoreSymlink "${projectRoot}/home/.ssh";
}
