{
  config,
  pkgs,
  myScriptsPath,
  ...
}:

{
  home.packages = with pkgs; [
    go
    rustup
    gcc
    gnumake # Nix 中通常使用 gnumake 而不是 make
    autoconf
    automake
    pkg-config
    netcat-openbsd
    net-tools
    wget
    bear
    cmake
    openssl
    clang-tools
    # vcpkg
    # musl
    # pkgsMusl.stdenv.cc
  ];

  home.sessionVariables = {
    GOPATH = "$HOME/go";
  };

  # Home Manager 会自动处理 PATH 的拼接
  home.sessionPath = [
    "$HOME/go/bin"
  ];
}
