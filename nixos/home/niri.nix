{
  config,
  pkgs,
  dms,
  myScriptsPath,
  ...
}:

{
  imports = [
    ./alacritty.nix
    ./fcitx5.nix
    ./autostart.nix
  ];
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
    config.lib.file.mkOutOfStoreSymlink "${myScriptsPath}/home/.config/niri";

  xdg.configFile."DankMaterialShell".source =
    config.lib.file.mkOutOfStoreSymlink "${myScriptsPath}/home/.config/DankMaterialShell";
}
