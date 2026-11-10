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

  home.file.".codex/models.json".source =
    config.lib.file.mkOutOfStoreSymlink "${projectRoot}/home/.codex/models.json";
  home.file.".codex/models.json".force = true;
}
