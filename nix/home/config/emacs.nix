{
  config,
  pkgs,
  projectRoot,
  ...
}:
{
  home.packages =
    with pkgs;
    [
      # doc
      pandoc
      multimarkdown
      mermaid-cli

      # spellcheck
      enchant
      emacsPackages.jinx
      hunspell
      hunspellDicts.en_US

      # nix
      nixd

      # go
      go
      gopls
      delve
      (lib.lowPrio gotools)
      gomodifytags
      gotests
      impl
      gogetdoc
      reftools

      # rust
      cargo
      rustc
      clippy
      rustfmt
      rust-analyzer

      # c
      gcc
      gdb

      # workspace
      direnv

      # shell
      shfmt
    ]
    ++ lib.optionals (!config.settings.enableGui) [
      pkgs.emacs-nox
    ];

  home.file.".config/emacs".source =
    config.lib.file.mkOutOfStoreSymlink "${projectRoot}/home/.config/emacs";
}
