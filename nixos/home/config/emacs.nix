{
  config,
  pkgs,
  myScriptsPath,
  ...
}:

{
  home.packages = with pkgs; [
    # spellcheck
    enchant
    emacsPackages.jinx
    hunspell
    hunspellDicts.en_US

    # nix
    nixd # nix语言服务器

    # go
    go
    gopls # gopls
    delve # dlv
    go-tools # 包含 staticcheck, keyify 等
    gotools # 包含 goimports, godoc, guru, gorename
    gomodifytags # gomodifytags
    gotests # gotests
    impl # impl
    gogetdoc # gogetdoc
    reftools # 包含 fillstruct

    # rust
    rust-analyzer
    cargo
    rustc

    # workspace
    direnv
  ];
  home.file.".config/emacs".source =
    config.lib.file.mkOutOfStoreSymlink "${myScriptsPath}/home/.config/emacs";
}
