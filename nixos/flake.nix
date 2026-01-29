{
  description = "我的 NixOS 配置：解耦虚拟机与物理机";

  nixConfig = {
    substituters = [
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
      "https://mirrors.nju.edu.cn/nix-channels/store"
      "https://cache.nixos.org"
    ];
    download-attempts = 1;
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
  # 特定版本的 nixpkgs (POT)
  nixpkgs-pot.url = "https://github.com/NixOS/nixpkgs/archive/e6f23dc08d3624daab7094b701aa3954923c6bbb.tar.gz";
  rust-overlay = {
    url = "github:oxalica/rust-overlay";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  flake-utils = {
    url = "github:numtide/flake-utils";
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
      ...
    }@inputs:
    let
      myScriptsPath = "/home/x/workspace/github/scripts";

      sharedHomeInfo = {
        home.username = "x";
        home.homeDirectory = "/home/x";
        home.stateVersion = "25.11";
      };

      getPkgs =
        system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

      getMyArgs = system: {
        inherit myScriptsPath;
        pot-fixed = nixpkgs-pot.legacyPackages.${system}.pot;
        nixpkgs-unstable = import nixpkgs-unstable {
          inherit system;
          config = {
            allowUnfree = true;
          };
        };

      };

      mkCommonModules = system: [
        ./configuration.nix
        ./desktop.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.extraSpecialArgs = getMyArgs system;
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
        pkgs = getPkgs system;
      in
      {
        # 这里定义的属性会被自动挂载到 devShells.${system} 下
        devShells = {
          # 在这里增加 system 的传递
          default = import ./develop/go.nix { inherit pkgs system; };
          go = import ./develop/go.nix { inherit pkgs system; };
          aarch64-go = import ./develop/aarch64-go.nix { inherit pkgs; };
          rust = import ./develop/rust.nix {
            inherit system;
            nixpkgs = inputs.nixpkgs; # 传递 nixpkgs 源码 (flake input)
            rust-overlay = inputs.rust-overlay; # 传递 rust-overlay
          };
        };

        packages.default = self.nixosConfigurations.x-vm.config.system.build.vm;
      }
    )
    // {
      # 顶层不随架构变化的输出
      homeConfigurations."x" = home-manager.lib.homeManagerConfiguration {
        pkgs = getPkgs "x86_64-linux";
        extraSpecialArgs = getMyArgs "x86_64-linux";
        modules = [
          ./home.nix
          sharedHomeInfo
        ];
      };

      nixosConfigurations = {
        x-laptop = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = getMyArgs "x86_64-linux";
          modules = (mkCommonModules "x86_64-linux") ++ [
            ./hardware-configuration.nix
            { nixpkgs.config.allowUnfree = true; }
          ];
        };

        x-vm = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = getMyArgs "x86_64-linux";
          modules = (mkCommonModules "x86_64-linux") ++ [
            {
              virtualisation.vmVariant = {
                virtualisation.memorySize = 4096;
                virtualisation.cores = 4;
                virtualisation.sharedDirectories.config_repo = {
                  source = myScriptsPath;
                  target = myScriptsPath;
                };
              };
            }
            { nixpkgs.config.allowUnfree = true; }
          ];
        };
      };
    };
}
