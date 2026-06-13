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
    initContent = ''
      [ -f "${projectRoot}/home/.zshrc" ] && source "${projectRoot}/home/.zshrc"
    '';
  };
  home.activation.zshConfig = config.lib.dag.entryAfter [ "linkGeneration" ] ''
    # 定义工具路径
    COREUTILS="${pkgs.coreutils}/bin"

    # 目标目录/文件路径
    TARGET_DIR="$(dirname ${targetConfig})"

    # 1. 删除旧的目录/文件（确保彻底覆盖）
    $COREUTILS/rm -rf "$TARGET_DIR"

    # 2. 确保父目录存在
    $COREUTILS/mkdir -p "$TARGET_DIR"

    # 3. 复制整个源目录/文件过去
    $COREUTILS/cp -af "${projectRoot}/home/.config/zsh" "$TARGET_DIR"

    ${pkgs.oh-my-posh}/bin/oh-my-posh config export --config cinnamon | \
      ${pkgs.jq}/bin/jq 'del(.blocks[].segments[] | select(.type == "spotify"))' > ${targetConfig}
  '';
}
