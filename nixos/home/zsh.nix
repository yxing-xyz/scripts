{
  config,
  pkgs,
  projectRoot,
  ...
}:
let
  targetConfig = "${config.home.homeDirectory}/.config/zsh/cinnamon-no-spotify.json";
in
{
  home.packages = [
    pkgs.zsh
    pkgs.oh-my-posh
    pkgs.jq
  ];

  programs.zsh = {
    enable = true;
    initExtra = ''
      [ -f "${projectRoot}/home/.zshrc" ] && source "${projectRoot}/home/.zshrc"
    '';
  };
  home.file.".config/zsh".source =
    config.lib.file.mkOutOfStoreSymlink "${projectRoot}/home/.config/zsh";
  home.file.".config/zsh".force = true;
  home.activation.generateOmpConfig = config.lib.dag.entryAfter [ "linkGeneration" ] ''
    mkdir -p $(dirname ${targetConfig})
    ${pkgs.oh-my-posh}/bin/oh-my-posh config export --config cinnamon | \
      ${pkgs.jq}/bin/jq 'del(.blocks[].segments[] | select(.type == "spotify"))' > ${targetConfig}
  '';
}
