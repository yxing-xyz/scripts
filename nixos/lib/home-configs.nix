{ inputs,projectRoot, stateVersion}:
let
  mkHome = username: homeDirectory: inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = inputs.nixpkgs.legacyPackages."x86_64-linux";
    modules = [
      ../home-cli.nix
      ../home-gui.nix
      {
        home = { inherit username homeDirectory stateVersion; };
        _module.args = { inherit inputs projectRoot; dms = inputs.dms; };
        nixpkgs.config.allowUnfree = true;
        targets.genericLinux.enable = true;
      }
    ];
  };
in {
  root = mkHome "root" "/root";
  x = mkHome "x" "/home/x";
}
