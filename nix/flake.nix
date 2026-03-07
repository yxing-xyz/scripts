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
    trusted-users = [
      "root"
      "@wheel"
      "*"
    ];
  };
inputs = {
    nixpkgs.url = "git+https://mirrors.nju.edu.cn/git/nixpkgs.git?ref=nixos-26.05&shallow=1";
    clash-verge.url = "github:nixos/nixpkgs/6da45c91d53dc318df7482a0be7c7bf47515e1e2";

    flake-parts.url = "git+https://github.com/hercules-ci/flake-parts.git?shallow=1";
    home-manager = {
      url = "git+https://github.com/nix-community/home-manager.git?ref=release-26.05&shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rust-overlay = {
      url = "git+https://github.com/oxalica/rust-overlay.git?shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dms = {
      url = "git+https://github.com/AvengeMedia/DankMaterialShell.git?ref=stable&shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    docker-nixpkgs = {
      url = "git+https://github.com/nix-community/docker-nixpkgs.git?shallow=1";
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
      clash-verge,
      ...
    }@inputs:
    let
      projectRoot = "/opt/scripts";
      stateVersion = "26.05";

      # 显式定义支持的系统架构列表
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
    in
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      # 1. 彻底删除不听话的 transposition，回归标准正统结构
      systems = supportedSystems;

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
          # 💡 核心修改：自动将对应架构的 nixpkgs 透传出去
          legacyPackages = nixpkgs.legacyPackages.${system};
          packages.nix-flakes = pkgs.callPackage ./pkgs/nix-flakes { };
          devShells = {
            default = pkgs.mkShell {
              buildInputs = [
                inputs.home-manager.packages.${system}.home-manager
              ];
              shellHook = ''
                echo "⚡ 容器原生 Home Manager 环境已就绪！"
                echo "👉 请执行: home-manager switch --flake .#code"
              '';
            };
            go = import ./develop/go.nix { inherit (ctx) pkgs system; };
            aarch64-go = import ./develop/aarch64-go.nix { inherit (ctx) pkgs; };
            rust = import ./develop/rust.nix { pkgs = ctx.rustPkgs; };
          };
        };

      flake =
        let
          nixosFactory = import ./lib/nixos-configs.nix { inherit inputs projectRoot stateVersion; };
          homeFactory = import ./lib/home-configs.nix { inherit inputs projectRoot stateVersion; };
        in
        {
          nixosConfigurations = {
            yoga = (nixosFactory "x86_64-linux").yoga;
            test = (nixosFactory "x86_64-linux").test;
          };
          homeConfigurations = {
            code = (homeFactory "x86_64-linux").code;
            x = (homeFactory "x86_64-linux").x;
          };
        };
    };
}
