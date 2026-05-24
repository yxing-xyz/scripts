{
  description = "我的 NixOS 配置：解耦虚拟机与物理机";

  nixConfig = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    substituters = [
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
      # "https://mirrors.nju.edu.cn/nix-channels/store"
      "https://niri.cachix.org"
      "https://nix-community.cachix.org"
      "https://cache.nixos.org"
    ];
    trusted-public-keys = [
      "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
    download-attempts = 3;
    system-features = [
      "gccarch-x86-64-v4"
    ];
  };
  inputs = {
    # 核心：使用 shallow=1 减少下载量
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # clashPkgs.url = "github:NixOS/nixpkgs/9cf7092bdd603554bd8b63c216e8943cf9b12512?shallow=1";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # 其他工具
    flake-utils.url = "github:numtide/flake-utils";

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dms = {
      url = "github:AvengeMedia/DankMaterialShell/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # niri = {
    #   url = "github:yaLTeR/niri/v25.11";
    #  inputs.nixpkgs.follows = "nixpkgs";
    # };
    # quickshell = {
    #   url = "git+https://git.outfoxxed.me/quickshell/quickshell?ref=v0.2";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    # noctalia = {
    #   url = "github:noctalia-dev/noctalia-shell/v4.4.0";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };
  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      rust-overlay,
      flake-utils,
      dms,
      ...
    }@inputs:
    let
      myScriptsPath = "/home/x/workspace/github/scripts";

      sharedHomeInfo = {
        home.username = "x";
        home.homeDirectory = "/home/x";
        home.stateVersion = "25.11";
      };
      makeSystemContext =
        system:
        let
          # 1. 实例化主 nixpkgs (取代原有的 getPkgs)
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          rustPkgs = pkgs.extend rust-overlay.overlays.default;
          clashPkgs = inputs.clashPkgs.legacyPackages.${system};
        in
        {
          # 这里的每一个 key，都能在 configuration.nix 的参数大括号里直接拿到
          inherit
            pkgs
            system
            myScriptsPath
            dms
            rustPkgs
            clashPkgs
            ;
          niri = inputs.niri;
        };
      x86Context = makeSystemContext "x86_64-linux";

      mkCommonModules = system: [
        ./configuration.nix
        ./desktop.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.extraSpecialArgs = makeSystemContext system;
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "nixbak";
          home-manager.users.x = {
            imports = [
              ./home.nix
              sharedHomeInfo
            ];
          };
        }
      ];

    in
    # 使用 flake-utils 处理多架构输出
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        ctx = makeSystemContext system;
      in
      {
        # 这里定义的属性会被自动挂载到 devShells.${system} 下
        devShells = {
          # 在这里增加 system 的传递
          default = import ./develop/go.nix { inherit (ctx) pkgs system; };
          go = import ./develop/go.nix { inherit (ctx) pkgs system; };
          aarch64-go = import ./develop/aarch64-go.nix { inherit (ctx) pkgs; };
          rust = import ./develop/rust.nix {
            pkgs = ctx.rustPkgs;
          };
        };

        packages.default = self.nixosConfigurations.x-vm.config.system.build.vm;
      }
    )
    // {
      nixosConfigurations = {
        x-laptop = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = builtins.removeAttrs x86Context [ "pkgs" ] // {
            inherit inputs;
          };
          modules = (mkCommonModules "x86_64-linux") ++ [
            ./hardware-configuration.nix
            {
              nixpkgs.pkgs = x86Context.pkgs;
              networking.hostName = "zen";
            }
          ];
        };

        x-vm = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = builtins.removeAttrs x86Context [ "pkgs" ] // {
            inherit inputs;
          };
          modules = (mkCommonModules "x86_64-linux") ++ [
            {
              virtualisation.vmVariant = {
                virtualisation.memorySize = 4096;
                virtualisation.cores = 4;
                # --- 关键配置：开启 QEMU 的硬件加速 ---
                virtualisation.qemu.options = [
                  "-device virtio-vga-gl"
                  "-display gtk,gl=on" # 或者 "-display sdl,gl=on"
                ];
                virtualisation.sharedDirectories.config_repo = {
                  source = myScriptsPath;
                  target = myScriptsPath;
                };
              };
              # 确保虚拟机内部驱动支持
              hardware.graphics.enable = true;
            }
            {
              nixpkgs.pkgs = x86Context.pkgs;
              networking.hostName = "void";
            }
          ];
        };
      };
    };
}
