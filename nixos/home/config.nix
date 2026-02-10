{ pkgs, lib, ... }:

{
  imports = [
    ./config/zellij.nix
    ./config/fastfetch.nix
    ./config/lazygit.nix
    ./config/git.nix
    ./config/ssh.nix
    ./config/zsh.nix
    ./config/gtk.nix
    ./config/fcitx5.nix
    ./config/autostart.nix
    ./config/emacs.nix
  ];
}
