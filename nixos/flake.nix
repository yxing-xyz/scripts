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
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-parts,
      home-manager,
      rust-overlay,
      dms,
      ...
    }@inputs:
    let
      projectRoot = "/opt/scripts";
    in
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" ];
      perSystem =
        { pkgs, system, ... }:
        let
          ctx = {
            inherit pkgs system;
            myScriptsPath = projectRoot;
            dms = inputs.dms;
            rustPkgs = pkgs.extend inputs.rust-overlay.overlays.default;
          };
        in
        {
          packages.docker-image = import ./docker-image.nix {
            inherit pkgs;
          };
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
          stateVersion = "26.11";
          homeManagerCommon = {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "nixbak";
            home-manager.extraSpecialArgs = {
              myScriptsPath = projectRoot;
              inherit (inputs) dms;
            };
            home-manager.users.x = {
              imports = [
                ./home-cli.nix
                ./home-gui.nix
              ];
              # 手动填入这些值
              home.username = "x";
              home.homeDirectory = "/home/x";
              home.stateVersion = stateVersion;
            };
            home-manager.users.root = {
              imports = [
                ./home-cli.nix
                ./home-gui.nix
              ];
              home.username = "root";
              home.homeDirectory = "/root";
              home.stateVersion = stateVersion;
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
                myScriptsPath = projectRoot; # 物理机/虚拟机子模块也能直接作为参数拿到
              };
            }
          ];
        in
        {
          debugVar = projectRoot;
          nixosConfigurations = {
            x = inputs.nixpkgs.lib.nixosSystem {
              system = "x86_64-linux";
              # 修复：使用 ++ 拼接列表，防止产生嵌套列表错误
              modules = mkCommonModules ++ [
                ./hardware-configuration.nix
                { networking.hostName = "x"; }
              ];
            };
            test = inputs.nixpkgs.lib.nixosSystem {
              system = "x86_64-linux";
              # 修复：使用 ++ 拼接列表
              modules = mkCommonModules ++ [
                {
                  networking.hostName = "test";
                  hardware.graphics.enable = true;
                  virtualisation.vmVariant = {
                    virtualisation.memorySize = 4096;
                    virtualisation.cores = 4;
                    virtualisation.qemu.options = [
                      "-device virtio-vga-gl"
                      "-display gtk,gl=on"
                    ];
                    virtualisation.sharedDirectories.config_repo = {
                      source = projectRoot;
                      target = projectRoot;
                    };
                  };
                }
              ];
            };
          };
          homeConfigurations = {
            "root" = inputs.home-manager.lib.homeManagerConfiguration {
              # 独立运行时，需要手动传递纯净的 pkgs
              pkgs = inputs.nixpkgs.legacyPackages."x86_64-linux";

              modules = [
                ./home-cli.nix # 复用你原有的用户配置
                {
                  home.username = "root";
                  home.homeDirectory = "/root";
                  home.stateVersion = stateVersion;
                }
                {
                  # 传递原本在 NixOS 下通过 extraSpecialArgs 注入的变量
                  _module.args = {
                    myScriptsPath = projectRoot;
                    inherit (inputs) dms;
                    # 如果你在 home.nix 里也用到了 inputs，可以一并加上：
                    inherit inputs;
                  };

                  # 允许在 Arch 下通过 nix 安装非自由软件
                  nixpkgs.config.allowUnfree = true;

                  # 告诉 Home Manager 自动管理它的 XDG 目录，以便在非 NixOS 正常查找应用
                  targets.genericLinux.enable = true;
                }
              ];
            };
            "x" = inputs.home-manager.lib.homeManagerConfiguration {
              # 独立运行时，需要手动传递纯净的 pkgs
              pkgs = inputs.nixpkgs.legacyPackages."x86_64-linux";

              modules = [
                ./home-cli.nix # 复用你原有的用户配置
                {
                  home.username = "x";
                  home.homeDirectory = "/home/x";
                  home.stateVersion = stateVersion;
                }
                {
                  # 传递原本在 NixOS 下通过 extraSpecialArgs 注入的变量
                  _module.args = {
                    myScriptsPath = projectRoot;
                    inherit (inputs) dms;
                    # 如果你在 home.nix 里也用到了 inputs，可以一并加上：
                    inherit inputs;
                  };

                  # 允许在 Arch 下通过 nix 安装非自由软件
                  nixpkgs.config.allowUnfree = true;

                  # 告诉 Home Manager 自动管理它的 XDG 目录，以便在非 NixOS 正常查找应用
                  targets.genericLinux.enable = true;
                }
              ];
            };
          };
        };
    };
}
