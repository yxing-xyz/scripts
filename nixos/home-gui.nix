{ pkgs, ... }:
{
  imports = [
    ./home/alacritty.nix
    ./home/gnome.nix
    ./home/niri.nix
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
      emacs-pgtk
  ];
}
