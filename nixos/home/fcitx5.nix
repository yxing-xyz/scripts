{
  config,
  pkgs,
  myScriptsPath,
  ...
}:

{
  home.file.".config/fcitx5".source =
    config.lib.file.mkOutOfStoreSymlink "${myScriptsPath}/home/.config/fcitx5";

    home.activation.setupRime = config.lib.dag.entryAfter [ "writeBoundary" ] ''
      RIME_DIR="$HOME/.local/share/fcitx5/rime"
      $DRY_RUN_CMD mkdir -p $VERBOSE_ARG "$RIME_DIR"

      # 1. 将系统路径下的雾凇拼音基础文件链接/拷贝过来（Rime 需要它们作为 __include 的基础）
      # 我们用 cp -sf (软链接) 系统预装的文件，这样不占空间
      $DRY_RUN_CMD ln -sf $VERBOSE_ARG /run/current-system/sw/share/rime-data/* "$RIME_DIR/"

      # 2. 物理拷贝你的自定义配置文件 (覆盖掉链接，确保可写)
      # 假设你的文件放在了 scripts/files/rime/default.custom.yaml
      $DRY_RUN_CMD cp -fL $VERBOSE_ARG "${myScriptsPath}/home/.local/share/fcitx5/rime/default.custom.yaml" "$RIME_DIR/default.custom.yaml"

      # 3. 修正权限，确保 Rime 部署时能写缓存
      $DRY_RUN_CMD chmod -R $VERBOSE_ARG 755 "$RIME_DIR"
    '';
}
