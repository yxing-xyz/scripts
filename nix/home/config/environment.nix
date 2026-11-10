{
  config,
  pkgs,
  projectRoot,
  ...
}:

{
  home.file.".config/environment.d/fcitx.conf" = {
    source = config.lib.file.mkOutOfStoreSymlink "${projectRoot}/home/.config/environment.d/fcitx.conf";
    force = true;
  };
}
