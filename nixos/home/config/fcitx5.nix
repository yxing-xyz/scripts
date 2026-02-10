{
  config,
  pkgs,
  myScriptsPath,
  ...
}:

{
  home.file.".config/fcitx5".source =
    config.lib.file.mkOutOfStoreSymlink "${myScriptsPath}/home/.config/fcitx5";

  # home.file.".local/share/fcitx5/rime/default.custom.yaml".source =
  #   config.lib.file.mkOutOfStoreSymlink "${myScriptsPath}/home/.local/share/fcitx5/rime/default.custom.yaml";

  home.activation.setupRime = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    RIME_DIR="$HOME/.local/share/fcitx5/rime"
    # 直接使用 pkgs.rime-ice 的路径，而不是系统运行路径
    ICE_DATA="/run/current-system/sw/share/rime-data"

    $DRY_RUN_CMD mkdir -p "$RIME_DIR"

    # 1. 自动清理已经断开的死链接（防止 ice 包删掉文件后留下垃圾）
    $DRY_RUN_CMD find "$RIME_DIR" -xtype l -delete

    # 2. 链接新文件
    $DRY_RUN_CMD ln -sf $VERBOSE_ARG $ICE_DATA/* "$RIME_DIR/"

    # 3. 覆盖自定义配置
    $DRY_RUN_CMD ln -sf $VERBOSE_ARG "${myScriptsPath}/home/.local/share/fcitx5/rime/default.custom.yaml" "$RIME_DIR/default.custom.yaml"
   '';
}
