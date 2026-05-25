{
  description = "我的 NixOS 配置：解耦虚拟机与物理机 (flake-parts 版)";

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
  };

  outputs =
    inputs:
    let
      globalScriptsPath = "/home/x/workspace/github/scripts";
    in
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];

      perSystem =
        { pkgs, system, ... }:
        let
          ctx = {
            inherit pkgs system;
            myScriptsPath = globalScriptsPath;
            dms = inputs.dms;
            rustPkgs = pkgs.extend inputs.rust-overlay.overlays.default;
          };
        in
        {
          devShells = {
            default = import ./develop/go.nix { inherit (ctx) pkgs system; };
            go = import ./develop/go.nix { inherit (ctx) pkgs system; };
            aarch64-go = import ./develop/aarch64-go.nix { inherit (ctx) pkgs; };
            rust = import ./develop/rust.nix { pkgs = ctx.rustPkgs; };
          };
        };

      flake =
        let
          # 修复：将公用路径变量定义在全局的 flake 作用域中，使 homeManager 能够正确抓取
          sharedHomeInfo = {
            home.username = "x";
            home.homeDirectory = "/home/x";
            home.stateVersion = "25.11";
          };

          homeManagerCommon = {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "nixbak";
            home-manager.extraSpecialArgs = {
              myScriptsPath = globalScriptsPath;
              inherit (inputs) dms;
            };
            home-manager.users.x = {
              imports = [
                ./home.nix
                sharedHomeInfo
              ];
            };
          };

          # 这是一个包含多个 Module 的 List
          mkCommonModules = [
            ./configuration.nix
            ./desktop.nix
            inputs.home-manager.nixosModules.home-manager
            homeManagerCommon
            {
              nixpkgs.config.allowUnfree = true;
              _module.args = {
                inherit inputs; # 满足你当前 configuration.nix 中对 inputs 的调用
                myScriptsPath = globalScriptsPath; # 物理机/虚拟机子模块也能直接作为参数拿到
              };
            }
          ];
        in
        {
          nixosConfigurations = {
            x-laptop = inputs.nixpkgs.lib.nixosSystem {
              system = "x86_64-linux";
              # 修复：使用 ++ 拼接列表，防止产生嵌套列表错误
              modules = mkCommonModules ++ [
                ./hardware-configuration.nix
                { networking.hostName = "zen"; }
              ];
            };

            x-vm = inputs.nixpkgs.lib.nixosSystem {
              system = "x86_64-linux";
              # 修复：使用 ++ 拼接列表
              modules = mkCommonModules ++ [
                {
                  networking.hostName = "void";
                  hardware.graphics.enable = true;
                  virtualisation.vmVariant = {
                    virtualisation.memorySize = 4096;
                    virtualisation.cores = 4;
                    virtualisation.qemu.options = [
                      "-device virtio-vga-gl"
                      "-display gtk,gl=on"
                    ];
                    virtualisation.sharedDirectories.config_repo = {
                      source = globalScriptsPath;
                      target = globalScriptsPath;
                    };
                  };
                }
              ];
            };
          };
        };
    };
}
