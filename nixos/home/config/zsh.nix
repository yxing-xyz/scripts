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
  home.file.".zshrc".source = config.lib.file.mkOutOfStoreSymlink "${projectRoot}/home/.zshrc";
  home.file.".zshrc".force = true;
  home.file.".config/zsh".source =
    config.lib.file.mkOutOfStoreSymlink "${projectRoot}/home/.config/zsh";
  home.file.".config/zsh".force = true;
  home.activation.generateOmpConfig = config.lib.dag.entryAfter [ "linkGeneration" ] ''
    echo "Generating Oh My Posh config..."
    ${pkgs.oh-my-posh}/bin/oh-my-posh config export --config cinnamon | \
      ${pkgs.jq}/bin/jq 'del(.blocks[].segments[] | select(.type == "spotify"))' > ${targetConfig}
  '';
}
