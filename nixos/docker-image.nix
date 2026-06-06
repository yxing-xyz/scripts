# 接收参数：pkgs（工具） + docker-nixpkgs（官方镜像库）
{ pkgs, docker-nixpkgs }:
let
  # 从pkgs获取文件生成工具
  inherit (pkgs) writeTextFile;

  # 基础镜像：官方 nix-flakes（已开启Flakes）
  baseImage = docker-nixpkgs.nix-flakes;
in
  # 直接override，只传我们的文件，官方会自动合并
  baseImage.override {
    # 直接定义你的文件，无需读取原有extraContents（根本不存在）
    extraContents = [
      # 你的自定义test文件
      (writeTextFile {
        name = "test-file";
        destination = "/root/test.txt";
        text = ''
          自定义测试文件
          基于官方nix-flakes构建
          Flakes已启用
        '';
      })
    ];
  }
