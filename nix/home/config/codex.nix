{
  config,
  lib,
  pkgs,
  projectRoot,
  ...
}:

{
  home.file.".codex/config.toml".source =
    config.lib.file.mkOutOfStoreSymlink "${projectRoot}/home/.codex/config.toml";
  home.file.".codex/config.toml".force = true;

}
