{
  description = "我的 NixOS 配置：解耦虚拟机与物理机";

  nixConfig = {
    substituters = [
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://cache.nixos.org"
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11?shallow=1";
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
    }@inputs:
    let
      system = "x86_64-linux";
      myScriptsPath = "/home/x/workspace/github/scripts";

      # 定义 pkgs，这是 homeManagerConfiguration 必须要求的参数
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true; # 关键：让 Home Manager 也有权安装 Chrome
      };

      # 变量注入定义
      pot-fixed = nixpkgs-pot.legacyPackages.${system}.pot;
      myArgs = { inherit pot-fixed myScriptsPath; };

      # 身份信息定义，两边共用
      sharedHomeInfo = {
        home.username = "x";
        home.homeDirectory = "/home/x";
        home.stateVersion = "25.11";
      };

      # 通用模块列表
      commonModules = [
        ./configuration.nix
        ./desktop.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.extraSpecialArgs = myArgs;
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

      vmConfig = {
        virtualisation.vmVariant = {
          virtualisation.memorySize = 4096;
          virtualisation.cores = 4;
          virtualisation.sharedDirectories.config_repo = {
            source = myScriptsPath;
            target = myScriptsPath;
          };
        };
      };
    in
    {
      nixosConfigurations = {
        x-laptop = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = myArgs;
          modules = commonModules ++ [
            ./hardware-configuration.nix
            { nixpkgs.pkgs = pkgs; }
          ];
        };

        x-vm = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = myArgs;
          modules = commonModules ++ [
            vmConfig
            { nixpkgs.pkgs = pkgs; }
          ];
        };
      };

      # 关键修正：独立模式入口
      homeConfigurations."x" = home-manager.lib.homeManagerConfiguration {
        # 必须传入 pkgs 实例
        inherit pkgs;

        # 注入变量
        extraSpecialArgs = myArgs;

        modules = [
          ./home.nix
          sharedHomeInfo
        ];
      };

      packages.${system}.default = self.nixosConfigurations.x-vm.config.system.build.vm;
    };
}
