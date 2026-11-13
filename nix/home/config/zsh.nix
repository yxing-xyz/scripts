{
  config,
  pkgs,
  projectRoot,
  ...
}:
let
cinnamonNoSpotify = pkgs.runCommand "cinnamon-no-spotify.json" {
  nativeBuildInputs = [ pkgs.oh-my-posh pkgs.jq ];
} ''
  jq 'del(.blocks[].segments[] | select(.type == "spotify"))' \
    ${pkgs.oh-my-posh}/share/oh-my-posh/themes/cinnamon.omp.json > $out
'';
in
{
  home.packages = [ pkgs.oh-my-posh pkgs.jq ];

  programs.zsh = {
    enable = true;
    # niri-session 用 `zsh -l -c` 启动并 import-environment，
    # 因此这里写进 .zshenv 的重排会同时影响 niri/DMS 等 GUI 程序的 PATH。
    # 目的：让 /usr/bin 等系统路径优先于 ~/.nix-profile/bin，
    # 避免 Home Manager 里的 coreutils/grep/sed/procps 等覆盖系统命令。
    envExtra = ''
      typeset -U path
      path=(
        /usr/local/bin
        /usr/bin
        /usr/local/sbin
        /usr/bin/site_perl
        /usr/bin/vendor_perl
        /usr/bin/core_perl
        $path
      )
      export PATH
    '';
    initContent = ''
      [ -f "${projectRoot}/home/.zshrc" ] && source "${projectRoot}/home/.zshrc"
    '';
  };
  xdg.configFile."zsh/themes".source =
     config.lib.file.mkOutOfStoreSymlink "${toString projectRoot}/home/.config/zsh/themes";
  xdg.configFile."zsh/cinnamon-no-spotify.json".source = cinnamonNoSpotify;
}
