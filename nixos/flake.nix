{
  description = "NixOS配置";

  nixConfig = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    substituters = [
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
      "https://niri.cachix.org"
      "https://nix-community.cachix.org"
      "https://cache.nixos.org"
    ];
    trusted-public-keys = [
      "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
    system-features = [ "gccarch-x86-64-v4" ];
    accept-flake-config = true;
    max-jobs = "auto";
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dms = {
      url = "github:AvengeMedia/DankMaterialShell/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    docker-nixpkgs = {
      url = "github:nix-community/docker-nixpkgs";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-parts,
      home-manager,
      rust-overlay,
      dms,
      docker-nixpkgs,
      ...
    }@inputs:
    let
      projectRoot = "/opt/scripts";
      stateVersion = "26.11";
    in
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      perSystem =
        { pkgs, system, ... }:
        let
          ctx = {
            inherit pkgs system;
            projectRoot = projectRoot;
            dms = inputs.dms;
            rustPkgs = pkgs.extend inputs.rust-overlay.overlays.default;
            docker-nixpkgs = import inputs.docker-nixpkgs {
              inherit system;
            };
          };
        in
        {
          packages.nix-flakes = pkgs.callPackage ./pkgs/nix-flakes { };
          devShells = {
            default = import ./develop/go.nix { inherit (ctx) pkgs system; };
            go = import ./develop/go.nix { inherit (ctx) pkgs system; };
            aarch64-go = import ./develop/aarch64-go.nix { inherit (ctx) pkgs; };
            rust = import ./develop/rust.nix { pkgs = ctx.rustPkgs; };
          };
        };

      flake = {
        nixosConfigurations = import ./lib/nixos-configs.nix { inherit inputs projectRoot stateVersion; };
        homeConfigurations = import ./lib/home-configs.nix { inherit inputs projectRoot stateVersion; };
      };
    };
}
