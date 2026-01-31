{
  description = "我的 NixOS 配置：解耦虚拟机与物理机";

  nixConfig = {
    substituters = [
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://cache.nixos.org" # 官方源作为保底
    ];
  };
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable?shallow=1";
    home-manager = {
      url = "github:nix-community/home-manager?shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur = {
      url = "github:nix-community/NUR?shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs-pot.url = "https://github.com/NixOS/nixpkgs/archive/e6f23dc08d3624daab7094b701aa3954923c6bbb.tar.gz";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      nur,
      nixpkgs-pot,
      ...
    }:
    let
      myScriptsPath = "/home/x/workspace/github/scripts";
      system = "x86_64-linux";
      # 通用配置：这里放你调试好的软件、用户、中文环境和改键逻辑
      commonModules = [
        ./configuration.nix
        ./desktop.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.extraSpecialArgs = { inherit myScriptsPath; };
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "nixbak";
          home-manager.users.x = import ./home.nix;
        }
      ];
      pot-fixed = nixpkgs-pot.legacyPackages.${system}.pot;
      # --- 新增：为 packages 定义 pkgs 变量 ---
      # pkgs = nixpkgs.legacyPackages.${system};

      vmConfig = {
        virtualisation.vmVariant = {
          virtualisation.memorySize = 4096;
          virtualisation.cores = 4;
          virtualisation.sharedDirectories = {
            config_repo = {
              source = myScriptsPath;
              target = myScriptsPath;
            };
          };
        };
      };
    in
    {
      nixosConfigurations = {
        # 1. 物理机配置
        # 目标主机名设为 my-pc，安装时使用：sudo nixos-rebuild switch --flake .#my-pc
        x-laptop = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit pot-fixed myScriptsPath; };
          modules = commonModules ++ [
            ./hardware-configuration.nix # 这里存放物理机的分区表和驱动
            vmConfig
          ];
        };

        # 2. 虚拟机配置
        # 运行构建：nix build .
        x-vm = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit pot-fixed myScriptsPath; };
          modules = commonModules ++ [
            ({ ... }: vmConfig)
          ];
        };
      };

      packages.${system} = {
        # 使用 callPackage 会自动传入 pot.nix 所需的依赖
        # pot = pkgs.callPackage ./pkgs/pot.nix { };
        default = self.nixosConfigurations.x-vm.config.system.build.vm;
      };
    };
}
