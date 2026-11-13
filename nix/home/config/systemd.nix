{
  config,
  projectRoot,
  ...
}:

{
  # 用户级 systemd 配置：缩短会话关停超时，避免 zsh 等忽略 SIGTERM 的进程
  # 让关机原地卡满 90 秒。
  xdg.configFile."systemd/user.conf".source =
    config.lib.file.mkOutOfStoreSymlink "${projectRoot}/home/.config/systemd/user.conf";

  xdg.configFile."systemd/user/niri.service.d/10-shutdown-timeout.conf".source =
    config.lib.file.mkOutOfStoreSymlink "${projectRoot}/home/.config/systemd/user/niri.service.d/10-shutdown-timeout.conf";
}
