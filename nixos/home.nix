# home.nix
{ pkgs, ... }: {
  imports = [
    ./home/zsh.nix
    ./home/gnome.nix
  ];
}
