# home.nix
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    grim
    slurp
    swappy
  ];
}
