{ pkgs, niri, ... }:
{
  imports = [
    ./home/gnome.nix
    ./home/niri.nix
  ];
}
