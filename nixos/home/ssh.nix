{
  config,
  pkgs,
  projectRoot,
  ...
}:

{
  home.activation.setupSSH = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    # 1. 显式定义所有工具路径
    COREUTILS="${pkgs.coreutils}/bin"

    # 2. 确保目录存在
    $COREUTILS/mkdir -p "$HOME/.ssh"

    # 5. 覆盖自定义配置
    $COREUTILS/cp -af "${projectRoot}/home/.ssh/config" "$HOME/.ssh/"
    $COREUTILS/cp -af "${projectRoot}/home/.ssh/authorized_keys" "$HOME/.ssh/"
    $COREUTILS/cp -af "${projectRoot}/home/.ssh/id_ed25519.pub" "$HOME/.ssh/"

    $COREUTILS/chmod 600 "$HOME/.ssh/config"
    $COREUTILS/chmod 600 "$HOME/.ssh/authorized_keys"
    $COREUTILS/chmod 644 "$HOME/.ssh/id_ed25519.pub"
  '';
}
