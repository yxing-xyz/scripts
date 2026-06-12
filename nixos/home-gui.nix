{ config, pkgs, ... }:
let
  isSystemGui = (config.osConfig.services.xserver.enable or false);
in
{
  imports = [
    ./home/alacritty.nix
    ./home/gnome.nix
    ./home/niri.nix
    ./home/swappy.nix
  ];

  home.packages = with pkgs; [
    (pkgs.symlinkJoin {
      name = "vscode-fhs-wrapped";
      paths = [ vscode-fhs ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/code --add-flags "--password-store=gnome-libsecret"
      '';
    })
    (if isSystemGui then pkgs.emacs-pgtk else pkgs.emacs-nox)
    zenity
  ];
}
