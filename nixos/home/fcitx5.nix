{
  config,
  pkgs,
  projectRoot,
  ...
}:

{
  home.packages = with pkgs; [
    librime
  ];
  home.file.".config/fcitx5".source =
    config.lib.file.mkOutOfStoreSymlink "${projectRoot}/home/.config/fcitx5";

  home.activation.setupRime = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    # 1. 显式定义所有工具路径
    FIND="${pkgs.findutils}/bin/find"
    COREUTILS="${pkgs.coreutils}/bin"

    RIME_DIR="$HOME/.local/share/fcitx5/rime"
    ICE_DATA="${pkgs.rime-ice}/share/rime-data"

    # 2. 确保目录存在
    $COREUTILS/mkdir -p "$RIME_DIR"

    # 3. 清理旧链接
    $FIND "$RIME_DIR" -maxdepth 1 -type l -delete

    # 4. 建立软链接 (避开 build 和 sync)
    for item in "$ICE_DATA"/*; do
        name=$(basename "$item")
        if [ "$name" != "build" ] && [ "$name" != "sync" ]; then
            $COREUTILS/ln -sf "$item" "$RIME_DIR/$name"
        fi
    done
    $COREUTILS/ln -sf "$RIME_DIR/rime_ice_suggestion.yaml" "$RIME_DIR/default.yaml"

    # 5. 覆盖自定义配置
    $COREUTILS/ln -sf "${projectRoot}/home/.local/share/fcitx5/rime/default.custom.yaml" "$RIME_DIR/default.custom.yaml"
    $COREUTILS/ln -sf "${projectRoot}/home/.local/share/fcitx5/rime/rime_ice.custom.yaml" "$RIME_DIR/rime_ice.custom.yaml"


    # 6. 清理旧缓存并写入安装标识 (确保部署环境一致性)
    $COREUTILS/rm -rf "$RIME_DIR/build"
  '';
}
