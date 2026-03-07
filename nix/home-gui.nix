{ config, pkgs, ... }:
{
  imports = [
    ./options.nix
    ./home/alacritty.nix
    ./home/gnome.nix
    ./home/niri.nix
    ./home/fcitx5.nix
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
    zenity
    vlc
    wireshark
    localsend
    nautilus
    loupe # 图片查看器
    # 办公与通讯
    google-chrome
    telegram-desktop
    ayugram-desktop
    wpsoffice-cn
    xournalpp
  ];
}
