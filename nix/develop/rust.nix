{
  pkgs,
}:

let
  # 1. 配置 Rust 工具链，包含交叉编译目标
  rustToolchain = pkgs.rust-bin.stable.latest.default.override {
    extensions = [ "rust-src" ];
    targets = [
      "x86_64-unknown-linux-gnu"
      "x86_64-unknown-linux-musl"
      "aarch64-unknown-linux-musl"
    ];
  };

  # 2. 为不同 Target 定义专属的 Zig 链接器包装脚本
  # 明确告诉 Zig 对应的目标，这样它会自动链接正确的 libc (glibc 或 musl)

  zig-gnu-linker = pkgs.writeShellScriptBin "zig-gnu-linker" ''
    exec ${pkgs.zig}/bin/zig cc -target x86_64-linux-gnu "$@"
  '';

  zig-musl-linker = pkgs.writeShellScriptBin "zig-musl-linker" ''
    exec ${pkgs.zig}/bin/zig cc -target x86_64-linux-musl "$@"
  '';

  zig-arm-musl-linker = pkgs.writeShellScriptBin "zig-arm-musl-linker" ''
    exec ${pkgs.zig}/bin/zig cc -target aarch64-linux-musl "$@"
  '';

in
pkgs.mkShell {
  name = "rust-with-zig-linker";

  packages = with pkgs; [
    rustToolchain
    zig
    rust-analyzer
    cargo-edit
    cargo-watch
    git
  ];

  # 3. 环境变量：将特定的目标映射到特定的包装脚本
  env = {
    # GNU 目标
    CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_LINKER = "${zig-gnu-linker}/bin/zig-gnu-linker";

    # MUSL 目标 (重点：指向带 -target x86_64-linux-musl 的脚本)
    CARGO_TARGET_X86_64_UNKNOWN_LINUX_MUSL_LINKER = "${zig-musl-linker}/bin/zig-musl-linker";

    # ARM MUSL 目标
    CARGO_TARGET_AARCH64_UNKNOWN_LINUX_MUSL_LINKER = "${zig-arm-musl-linker}/bin/zig-arm-musl-linker";

    # 可选：如果你希望默认的 cargo build 也用 zig 链接
    RUSTFLAGS = "-C link-self-contained=no";
  };

  shellHook = ''
    echo "===================================================="
    echo "🚀 Rust 交叉编译环境 (Zig Linker) 已就绪"
    echo "可用目标:"
    echo "  - x86_64-unknown-linux-gnu  (使用 zig cc)"
    echo "  - x86_64-unknown-linux-musl (使用 zig cc musl)"
    echo "  - aarch64-unknown-linux-musl"
    echo "===================================================="
  '';
}
