{
  config,
  pkgs,
  myScriptsPath,
  ...
}:

{

  # 确保已经安装了 fcitx5 和 rime
  i18n.inputMethod = {
    enable = true; # 新的开启方式
    # 2. 明确指定输入法框架类型
    type = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-rime
      rime-data
      rime-ice
      # 改为下面这样，明确指向 qt6Packages
      qt6Packages.fcitx5-chinese-addons
      fcitx5-gtk
      # 同样的，配置工具也建议用这个，兼容性更好
      qt6Packages.fcitx5-configtool
    ];
  };
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
