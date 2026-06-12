{
  config,
  pkgs,
  projectRoot,
  ...
}:
{
  home.packages = with pkgs; [
    # doc
    pandoc
    multimarkdown
    # 建议同时安装 mermaid-cli，如果你后续想用它做离线转换
    mermaid-cli

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
    delve
    # dlv
    (lib.lowPrio pkgs.gotools) # 它是配角，冲突时让位
    gomodifytags # gomodifytags
    gotests # gotests
    impl # impl
    gogetdoc # gogetdoc
    reftools # 包含 fillstruct

    # rust
    rust-analyzer
    cargo
    rustc

    # c
    gcc
    gdb

    # workspace
    direnv
  ];
  home.file.".config/emacs".source =
    config.lib.file.mkOutOfStoreSymlink "${projectRoot}/home/.config/emacs";
}
