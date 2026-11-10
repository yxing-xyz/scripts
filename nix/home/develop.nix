{
  config,
  pkgs,
  projectRoot,
  ...
}:

{
  home.packages = with pkgs; [
    gcc
    gdb
    gnumake # Nix 中通常使用 gnumake 而不是 make
    autoconf
    automake
    pkg-config
    wget
    bear
    cmake
    clang-tools
    # vcpkg
    # musl
  ];

  home.sessionVariables = {
    GOPATH = "$HOME/go";
  };

  # Home Manager 会自动处理 PATH 的拼接
  home.sessionPath = [
    "$HOME/go/bin"
  ];

  home.file.".npmrc" = {
    source =     config.lib.file.mkOutOfStoreSymlink "${projectRoot}/home/.npmrc";
    force =true;
  };

  home.file.".gitconfig"  =  {
      source = config.lib.file.mkOutOfStoreSymlink "${projectRoot}/home/.gitconfig";
      force = true;
  };
}
