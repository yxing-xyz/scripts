{ pkgs, lib, ... }:

{
  # 关键点：将软件包与配置绑定
  home.packages = with pkgs; [
    zsh
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
      # 核心三個選項：
      expireDuplicatesFirst = true; # 當超過歷史上限時，優先刪除重複的
      ignoreDups = true; # 如果這條命令跟上一條一模一樣，就不記錄
      ignoreAllDups = true; # 只要歷史裡有過這條命令，就把舊的刪掉，只記最新的（最強去重）
      # 其他實用配置
      share = true; # 多個 Terminal 窗口共享歷史記錄
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

    # 3. Oh My Zsh 插件与库
    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
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
      # 暴力注入 Go bin 路径，确保它在最前面且一定生效
      # export PATH="$HOME/go/bin:$PATH"
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
      bindkey -e # 启用 Emacs 模式
      bindkey -d # 恢复默认键位

      # Zsh clip to xorg clipboard 逻辑
      if [[ -n $DISPLAY ]] || [[ "$OSTYPE" == darwin* ]]; then
        x-copy-region-as-kill() {
          zle copy-region-as-kill
          print -rn $CUTBUFFER | clipcopy
        }
        zle -N x-copy-region-as-kill

        x-kill-region() {
          if (($REGION_ACTIVE == 1)); then
            zle copy-region-as-kill
            print -rn $CUTBUFFER | clipcopy
            zle kill-region
          else
            zle backward-kill-word
            print -rn $CUTBUFFER | clipcopy
          fi
        }
        zle -N x-kill-region

        x-yank() {
          CUTBUFFER=$(clippaste)
          zle yank
        }
        zle -N x-yank

        x-kill-line() {
          zle kill-line
          print -rn -- "$CUTBUFFER" | clipcopy
        }
        zle -N x-kill-line

        # 正确的按键绑定语法
        bindkey '\ew' x-copy-region-as-kill
        bindkey '^W' x-kill-region
        bindkey '^Y' x-yank
        bindkey '^K' x-kill-line
      fi

      x-input-current-path() {
        CUTBUFFER=$(pwd)
        zle yank
      }
      zle -N x-input-current-path
      bindkey '^[\' x-input-current-path

      x-input-empty-dir() {
        CUTBUFFER='rm -rf ./*'
        zle yank
      }
      zle -N x-input-empty-dir
      bindkey '^[`' x-input-empty-dir

      x-backward-delete-char() {
        if (($REGION_ACTIVE == 1)); then
          zle kill-region
        else
          zle backward-delete-char
        fi
      }
      zle -N x-backward-delete-char

      x-delete-char() {
        if (($REGION_ACTIVE == 1)); then
          zle kill-region
        else
          zle delete-char
        fi
      }
      zle -N x-delete-char

      bindkey '^?' x-backward-delete-char
      bindkey '^[[3~' x-delete-char
      bindkey '^x^e' edit-command-line

      # FZF 配置
      bindkey '^S' fzf-history-widget
      bindkey '\e[' fzf-file-widget
      bindkey '\e]' fzf-cd-widget

      # 还原 Emacs 快捷键
      bindkey '\el' down-case-word
      bindkey -s '\e^M' 'ls -lh\n'
      bindkey '\ec' capitalize-word
      bindkey '^T' transpose-chars

      # Alacritty & Zellij 自动挂载
      if [ ! -z "''${ALACRITTY_LOG+x}" ]; then
        if [[ -z "$ZELLIJ" ]]; then
          zellij attach -c
        fi
      fi
    '';
  };
}
