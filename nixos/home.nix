# home.nix
{ pkgs, ... }: {
  home.stateVersion = "25.11";
  imports = [
    ./home/zsh.nix
    ./home/gnome.nix
  ];
}
