{
  config,
  pkgs,
  projectRoot,
  ...
}:
let
cinnamonNoSpotify = pkgs.runCommand "cinnamon-no-spotify.json" {
  nativeBuildInputs = [ pkgs.oh-my-posh pkgs.jq ];
} ''
  jq 'del(.blocks[].segments[] | select(.type == "spotify"))' \
    ${pkgs.oh-my-posh}/share/oh-my-posh/themes/cinnamon.omp.json > $out
'';
in
{
  home.packages = [ pkgs.oh-my-posh pkgs.jq ];

  programs.zsh = {
    enable = true;
    initContent = ''
      [ -f "${projectRoot}/home/.zshrc" ] && source "${projectRoot}/home/.zshrc"
    '';
  };
  xdg.configFile."zsh/themes".source =
     config.lib.file.mkOutOfStoreSymlink "${toString projectRoot}/home/.config/zsh/themes";
  xdg.configFile."zsh/cinnamon-no-spotify.json".source = cinnamonNoSpotify;
}
