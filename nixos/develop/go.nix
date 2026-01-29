{ pkgs ? import <nixpkgs> {}, system }:

let
  # 辅助函数，方便判断系统类型
  isArm = system == "aarch64-linux" || system == "aarch64-darwin";
  isLinux = pkgs.stdenv.isLinux;
in
pkgs.mkShell {
  name = "go";

  # 负责编译工具（在宿主机运行）
  nativeBuildInputs = with pkgs; [
    go
    gopls
    pkg-config # 建议加上这个，Go 调用 C 库通常需要它
  ];

  # 负责目标库（链接进程序）
  buildInputs = with pkgs; [
    libpcap
  ];

  # 使用 shellHook 动态注入
  shellHook = ''
    echo "Developing on system: ${system}"

    # 示例：根据架构动态设置 GOARCH
    export GOARCH="${if isArm then "arm64" else "amd64"}"

    # 或者使用 Nix 的 lib 工具进行更复杂的判断
    ${pkgs.lib.optionalString isLinux ''
      export GOOS="linux"
      echo "Linux specific settings applied"
    ''}
  '';
}
