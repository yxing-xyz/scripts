{ pkgs }:

let
  # 官方镜像引用
  base = pkgs.dockerTools.pullImage {
    imageName = "nixos/nix";
    imageDigest = "sha256:bf1d938835ab96312f098fa6c2e9cab367728e0aad0646ee3e02a787c80d8fb8";
    sha256 = "sha256-fjUfF6h82wBvWsuw2bd8Cgl+mwLDA2Q0NDb/KHAGY2c=";
  };

  # 自定义的 Nix 配置
  nixConfig = pkgs.runCommand "nix-config" {} ''
    mkdir -p $out/etc/nix
    echo "experimental-features = nix-command flakes" > $out/etc/nix/nix.conf
  '';
in

pkgs.dockerTools.buildLayeredImage {
  name = "registry.cn-hangzhou.aliyuncs.com/yxing-xyz/linux";
  tag = "nix";

  # 继承官方镜像的层
  fromImage = base;

  # 在官方镜像基础上添加你的工具
  contents = [
    nixConfig
    pkgs.git
    pkgs.zsh
    pkgs.coreutils
    pkgs.vim
  ];

  # 这里依然可以添加你特有的脚本或目录，但不需要再碰 shadowSetup
  extraCommands = ''

  '';

  config = {
    # 官方镜像默认提供了很好的环境变量，这里做补充即可
    Env = [
      "PATH=/bin:/usr/bin:/usr/local/bin"
      "EDITOR=vim"
    ];
    Cmd = [ "/bin/zsh" ];
  };
}
