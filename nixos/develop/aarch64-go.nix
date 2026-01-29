
{ pkgs ? import <nixpkgs> {} }:

let
  sysroot = "/home/x/x-tools/debian-bullseye-arm64";
in
pkgs.mkShell {
  name = "zig-cross-shell";

  # nativeBuildInputs 包含运行在宿主机（x86_64）上的工具
  nativeBuildInputs = with pkgs; [
    zig
    go
  ];

  # 直接在 shellHook 里注入环境变量
  shellHook = ''
    export SYSROOT='${sysroot}'
    export PKG_CONFIG="true"
    export CC="zig cc -target aarch64-linux-gnu.2.31"

    export CGO_ENABLED=1
    export GOOS=linux
    export GOARCH=arm64
    export CGO_CFLAGS="-isystem $SYSROOT/usr/include \
                        -isystem $SYSROOT/usr/include/aarch64-linux-gnu \
                        -isystem $SYSROOT/usr/include/vips \
                        -isystem $SYSROOT/usr/include/glib-2.0 \
                        -isystem $SYSROOT/usr/lib/glib-2.0/include"
    export CGO_LDFLAGS="--sysroot=$SYSROOT \
                        -L/usr/lib/ \
                        -lvips -lgobject-2.0 -lglib-2.0 -lpcap -lc"
  '';
}
