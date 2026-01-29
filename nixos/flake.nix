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
      "https://cache.nixos.org"
      "https://niri.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
    ];
    download-attempts = 3;
  };
  inputs = {
    # 主系统通道
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11?shallow=1";
    # 不稳定版本（用于获取最新软件）
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable?shallow=1";
    # Home Manager - 锁定 nixpkgs
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
    # 特定版本的 nixpkgs (POT)
    nixpkgs-pot.url = "https://github.com/NixOS/nixpkgs/archive/e6f23dc08d3624daab7094b701aa3954923c6bbb.tar.gz";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
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
    dms = {
      url = "github:AvengeMedia/DankMaterialShell/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };
  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      nur,
      nixpkgs-pot,
      rust-overlay,
      flake-utils,
      nixpkgs-unstable,
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
            overlays = [
              rust-overlay.overlays.default # 加上这一行
              # 你其他的 overlay 也可以放这里
            ];
          };

          # 2. 实例化不稳定版 (用于获取最新软件)
          unstable = import nixpkgs-unstable {
            inherit system;
            config.allowUnfree = true;
          };
        in
        {
          # 这里的每一个 key，都能在 configuration.nix 的参数大括号里直接拿到
          inherit
            pkgs
            system
            myScriptsPath
            dms
            ;
          # 这里的命名可以根据你的习惯调整
          pot-fixed = nixpkgs-pot.legacyPackages.${system}.pot;
          nixpkgs-unstable = unstable;
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
            inherit (ctx) pkgs;
          };
        };

        packages.default = self.nixosConfigurations.x-vm.config.system.build.vm;
      }
    )
    // {
      # 顶层不随架构变化的输出
      homeConfigurations."x" = home-manager.lib.homeManagerConfiguration {
        pkgs = x86Context.pkgs;
        extraSpecialArgs = builtins.removeAttrs x86Context [ "pkgs" ];
        modules = [
          ./home.nix
          sharedHomeInfo
        ];
      };

      nixosConfigurations = {
        x-laptop = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = builtins.removeAttrs x86Context [ "pkgs" ];
          modules = (mkCommonModules "x86_64-linux") ++ [
            ./hardware-configuration.nix
            { nixpkgs.config.allowUnfree = true; }
          ];
        };

        x-vm = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = builtins.removeAttrs x86Context [ "pkgs" ];
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
            { nixpkgs.config.allowUnfree = true; }
          ];
        };
      };
    };
}
