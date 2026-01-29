{ pkgs, lib, ... }:

{
  imports = [
    ./zellij.nix
    ./fastfetch.nix
    ./lazygit.nix
    ./git.nix
    ./ssh.nix
  ];
  # 关键点：将软件包与配置绑定
  home.packages = with pkgs; [
    bat
    lsd
    fzf
    zoxide
    fd
    trash-cli
    sshuttle
    yazi
  ];
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # 1. 环境变量与历史记录
    history = {
      size = 10000000;
      save = 10000000;
      path = "$HOME/.zsh_history";
      share = true;
    };

    sessionVariables = {
      EDITOR = "emacsclient -t";
      LANG = "zh_CN.UTF-8";
      LC_CTYPE = "zh_CN.UTF-8";
      COLORTERM = "truecolor";
      TRZSZ_ENABLE = "trzsz";
      RUSTUP_UPDATE_ROOT = "https://mirrors.aliyun.com/rustup/rustup";
      RUSTUP_DIST_SERVER = "https://mirrors.aliyun.com/rustup";
      VCPKG_ROOT = "$HOME/.local/share/vcpkg";

      # FZF 默认选项
      FZF_DEFAULT_OPTS = "--no-mouse --height 50% --reverse --multi --inline-info --preview 'bat --style=numbers --color=always --line-range :500 {} 2> /dev/null'";
      FZF_ALT_C_COMMAND = "fd -t d --follow 2> /dev/null";
      FZF_CTRL_T_COMMAND = "fd --follow --exclude .git 2> /dev/null";
    };

    # 2. 别名 (Aliases)
    shellAliases = {
      ".." = "cd ..";
      "..." = "cd ../..";
      ".3" = "cd ../../..";
      ".4" = "cd ../../../..";
      ".5" = "cd ../../../../..";
      c = "clear";
      rm = "trash-put";
      mkdir = "mkdir -p";
      # ls = lib.mkForce "lsd";
      tree = "ls --tree";
      cat = "bat";
      diff = "difft --display inline";
      lzg = "lazygit";
      et = "emacsclient -t";
      er = "emacsclient -r";
      eq = "emacs -nw -q";
      # 整合 trzsz 与 远程 alias
      ssh = "TERM=xterm-256color $TRZSZ_ENABLE ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null";
      docker = "TERM=xterm-256color $TRZSZ_ENABLE docker";
      lzd = "$TRZSZ_ENABLE lazydocker";
      k9s = "$TRZSZ_ENABLE k9s";
      bj = "sshuttle --dns -vr root@60.205.202.6 10.0.0.0/8 172.16.0.0/12 --ssh-cmd \"ssh -i $HOME/.ssh/品牌中心.key\"";
      hz = "sshuttle --dns -vr root@112.124.55.199 10.0.0.0/8 192.168.0.0/16 --ssh-cmd \"ssh -i $HOME/.ssh/品牌中心.key\"";
      # 原地启动 yazi
      yy = "yazi";
      # 先通过 zoxide 交互式选择目录，然后直接用 yazi 打开
      yz = "zoxide query -i | xargs -r yazi";
    };

    # 3. Oh My Zsh 插件与库 (替代大部分 zinit snippet)
    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell"; # 你可以换成 eastwood, garyblessington 等
      plugins = [
        "git"
        "svn"
        "extract"
        "colored-man-pages"
        "history"
      ];
    };

    # 4. 核心脚本、函数与按键绑定 (ZLE)
    initContent = ''
      # 自定义函数
      cheat.sh() { curl -L cheat.sh/$1; }

      shutdownAfter() {
          while [ true ]; do
              pgrep $1 >/dev/null 2>&1
              if (($? != 0)); then break; fi
              sleep 10
          done
          shutdown -h now
      }

      setProxy() {
          case $1 in
              start)
                  local PROXY_SERVER="127.0.0.1:10808"
                  export http_proxy="http://$PROXY_SERVER"
                  export https_proxy="http://$PROXY_SERVER"
                  export all_proxy="socks5://$PROXY_SERVER"
                  echo "Proxy started."
                  ;;
              stop)
                  unset http_proxy https_proxy all_proxy
                  echo "Proxy stopped."
                  ;;
          esac
      }

      # --- ZLE & Bindkeys ---
      bindkey -e # 使用 Emacs 模式

      # FZF 绑定
      bindkey '^S' fzf-history-widget
      bindkey '\e[' fzf-file-widget
      bindkey '\e]' fzf-cd-widget

      # 还原 Emacs 快捷键
      bindkey '\el' down-case-word
      bindkey -s '\e^M' 'ls -lh\n'
      bindkey '\ec' capitalize-word
      bindkey '^T' transpose-chars
      bindkey '^x^e' edit-command-line

      # 自定义 ZLE 小部件 (路径输入、清空目录等)
      x-input-current-path() { CUTBUFFER=$(pwd); zle yank; }
      zle -N x-input-current-path
      bindkey '^[\' x-input-current-path

      x-input-empty-dir() { CUTBUFFER='rm -rf ./*'; zle yank; }
      zle -N x-input-empty-dir
      bindkey '^[`' x-input-empty-dir

      # 剪贴板增强逻辑 (适配 X11/Darwin)
      # 注意：clipcopy 是 OMZ clipboard 插件提供的
      x-copy-region-as-kill() { zle copy-region-as-kill; print -rn $CUTBUFFER | clipcopy; }
      zle -N x-copy-region-as-kill
      bindkey '\ew' x-copy-region-as-kill

      # Alacritty & Zellij 自动挂载
      if [ ! -z "''${ALACRITTY_LOG+x}" ]; then
          if [[ -z "$ZELLIJ" ]]; then
              zellij attach -c
          fi
      fi
    '';
  };

  # 配合 Zsh 所需的工具 (Home Manager 会自动处理安装)
  programs.zoxide.enable = true;
  programs.fzf.enable = true;
  programs.bat.enable = true;
  programs.lsd.enable = true;
}
