{
  config,
  pkgs,
  myScriptsPath,
  ...
}:

{
  home.packages = with pkgs; [
    go
    gopls             # gopls
    delve             # dlv
    go-tools          # 包含 staticcheck, keyify 等
    gotools           # 包含 goimports, godoc, guru, gorename
    gomodifytags      # gomodifytags
    gotests           # gotests
    impl              # impl
    gogetdoc          # gogetdoc
    reftools          # 包含 fillstruct    
    rust-analyzer
    cargo
    rustc
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
