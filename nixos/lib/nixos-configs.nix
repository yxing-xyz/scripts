{
  inputs,
  projectRoot,
  stateVersion,
}:
# 1. 包装一层，让它接受 system 参数，或者你也可以将其直接作为上面的参数传递
# 这里我们采用函数柯里化的方式，外面调用时传入 system (比如 nixosConfigs "x86_64-linux")
system:
let
  # 统一的 Home Manager 配置模块
  homeManagerCommon = {
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.backupFileExtension = "nixbak";
    home-manager.extraSpecialArgs = {
      inherit inputs projectRoot;
      dms = inputs.dms;
    };

    # 自动定义用户配置
    home-manager.users = {
      x = {
        imports = [
          ../home-cli.nix
          ../home-gui.nix
        ];
        home = {
          username = "x";
          homeDirectory = "/home/x";
          inherit stateVersion;
        };
      };
      root = {
        imports = [
          ../home-cli.nix
        ];
        home = {
          username = "root";
          homeDirectory = "/root";
          inherit stateVersion;
        };
      };
    };
  };

  commonModules = [
    ../configuration.nix
    ../graphical.nix
    inputs.home-manager.nixosModules.home-manager
    homeManagerCommon
    {
      nixpkgs.config.allowUnfree = true;
      _module.args = {
        inherit inputs projectRoot stateVersion;
      };
    }
  ];
in
{
  # 2. 将原本硬编码的 "x86_64-linux" 全部替换为外部传入的 system 变量
  x = inputs.nixpkgs.lib.nixosSystem {
    inherit system;
    modules = commonModules ++ [
      ../hardware-configuration.nix
      {
        networking.hostName = "x";
        boot.loader.grub.enable = inputs.nixpkgs.lib.mkForce true; # 强制物理机启用 GRUB
      }
    ];
  };

  test = inputs.nixpkgs.lib.nixosSystem {
    inherit system;
    modules = commonModules ++ [
      {
        networking.hostName = "test";
        hardware.graphics.enable = true;
        virtualisation.vmVariant = {
          virtualisation = {
            memorySize = 4096;
            cores = 4;
            qemu.options = [
              "-device virtio-vga-gl"
              "-display gtk,gl=on"
            ];
            sharedDirectories.config_repo = {
              source = projectRoot;
              target = projectRoot;
            };
          };
        };
      }
    ];
  };
}
