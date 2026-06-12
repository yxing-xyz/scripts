{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

{
  # 1. 定义你的自定义选项
  options.settings = {
    enableGui = mkOption {
      type = types.bool;
      default = false;
      description = "是否启用 GUI 环境";
    };
  };
}
