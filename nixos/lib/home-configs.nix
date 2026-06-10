{
  inputs,
  projectRoot,
  stateVersion,
}:
let
  mkHome =
    username: homeDirectory:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = inputs.pkgs;
      modules = [
        ../home-cli.nix
        {
          home = { inherit username homeDirectory stateVersion; };
          _module.args = {
            inherit inputs projectRoot;
            dms = inputs.dms;
          };
          nixpkgs.config.allowUnfree = true;
          targets.genericLinux.enable = true;
        }
      ];
    };
in
{
  root = mkHome "root" "/root";
  code = mkHome "x" "/home/x";
  # x 用户：在原有基础上叠加 home-gui.nix
  x = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = inputs.pkgs;
    modules = [
      (mkHome "x" "/home/x") # 先复用 mkHome 整套配置
      ../home-gui.nix # 再追加 GUI 模块
    ];
  };
}
