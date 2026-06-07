{
  config,
  pkgs,
  dms,
  projectRoot,
  ...
}:

{
  home.packages = with pkgs; [
    niri
    quickshell
    dms.packages.${pkgs.stdenv.hostPlatform.system}.default
    # niri.packages.${pkgs.stdenv.hostPlatform.system}.default
    # quickshell.packages.${pkgs.stdenv.hostPlatform.system}.default
    # noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
    cava
    matugen
  ];
  xdg.configFile."niri".source =
    config.lib.file.mkOutOfStoreSymlink "${projectRoot}/home/.config/niri";

  xdg.configFile."DankMaterialShell".source =
    config.lib.file.mkOutOfStoreSymlink "${projectRoot}/home/.config/DankMaterialShell";
}
