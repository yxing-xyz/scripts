{ pkgs, ... }:

{
  # 1. 软件包安装
  home.packages = with pkgs; [
    fish
  ];
  programs.starship = {
    enable = true;
  };
  programs.fish = {
    enable = true;

    # 别名 (Aliases)
    shellAliases = {
      ".." = "cd ..";
      "..." = "cd ../..";
      ".3" = "cd ../../..";
      c = "clear";
      rm = "trash-put";
      mkdir = "mkdir -p";
      tree = "ls --tree";
      cat = "bat";
      lzg = "lazygit";
      yy = "yazi";
      # 整合 trzsz
      ssh = "TERM=xterm-256color $TRZSZ_ENABLE ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null";
      docker = "TERM=xterm-256color $TRZSZ_ENABLE docker";
      lzd = "$TRZSZ_ENABLE lazydocker";
      k9s = "$TRZSZ_ENABLE k9s";
      bj = "sshuttle --dns -vr root@60.205.202.6 10.0.0.0/8 172.16.0.0/12 --ssh-cmd \"ssh -i $HOME/.ssh/品牌中心.key\"";
      hz = "sshuttle --dns -vr root@112.124.55.199 10.0.0.0/8 192.168.0.0/16 --ssh-cmd \"ssh -i $HOME/.ssh/品牌中心.key\"";
    };

    # 函数重构 (对应原 Zsh functions)
    functions = {
      "cheat.sh" = "curl -L cheat.sh/$argv[1]";

      setProxy = ''
        switch $argv[1]
          case start
            set -gx http_proxy "http://127.0.0.1:10808"
            set -gx https_proxy "http://127.0.0.1:10808"
            set -gx all_proxy "socks5://127.0.0.1:10808"
            echo "Proxy started."
          case stop
            set -e http_proxy https_proxy all_proxy
            echo "Proxy stopped."
        end
      '';

      # 模拟 yz 逻辑
      yz = "zoxide query -i | xargs -r yazi";
    };

    # 交互式初始化与按键绑定 (对应原 ZLE 逻辑)
    interactiveShellInit = ''
      set -g fish_greeting "" # 禁用欢迎语
      # 还原emacs按键
      bind \e\x7f backward-kill-word   # 匹配 Alt + Backspace

      # 设置fzf按键
      fzf --fish | source
      set FZF_DEFAULT_OPTS  "--no-mouse --height 70% --reverse --multi --inline-info --preview 'if test -d {}; lsd --tree --depth 5 --color always {}; else; bat --style=numbers --color=always --line-range :10000 {} 2>/dev/null; end' --bind 'ctrl-/:toggle-preview'";
      set FZF_ALT_C_COMMAND "fd -t d --follow 2> /dev/null";
      set FZF_CTRL_T_COMMAND "fd --follow --exclude .git 2> /dev/null";
      bind -e \ct        # 取消原来的 Ctrl + t (搜文件)
      bind -e \ec        # 取消原来的 Alt + c (搜目录)
      bind -e \cr        # 如果你想彻底重新定义 Ctrl + r 也可以删掉它
      bind \e9 fzf-file-widget
      bind -M insert \e9 fzf-file-widget
      bind \e0 fzf-cd-widget
      bind -M insert \e0 fzf-cd-widget
      bind \cr "FZF_DEFAULT_OPTS=\"$FZF_DEFAULT_OPTS --no-preview\" fzf-history-widget"
      bind -M insert \cr "FZF_DEFAULT_OPTS=\"$FZF_DEFAULT_OPTS --no-preview\" fzf-history-widget"

      # 自定义按键
      bind \e\\ 'commandline -i (pwd)'        # Alt + \ 输入当前路径
      bind \e\` 'commandline -r "rm -rf ./*"' # Alt + ` 输入危险命令
      bind \ck 'fish_clipboard_copy; commandline -r ""'  # 模拟 Ctrl+K: 复制整行到剪贴板并清空当前行
      bind \cy 'fish_clipboard_paste'  # 模拟 Ctrl+Y: 从剪贴板粘贴到光标处

      # 1. 标记
      bind ctrl-space begin-selection
      # 2. 静默复制函数 (Alt + w)
      function x_copy_to_clipboard
          set -l selection (commandline -s)
          if test -n "$selection"
              # 纯净拷贝，不输出任何内容
              echo -n "$selection" | fish_clipboard_copy
              # 取消高亮选区
              commandline -f end-selection
          end
          # 强制重绘命令行，确保高亮立即消失
          commandline -f repaint
      end
      bind \ew x_copy_to_clipboard
      # 3. 静默智能剪切函数 (Ctrl + w)
      function x_kill_region_smart
          set -l selection (commandline -s)
          if test -n "$selection"
              # 1. 拷贝到剪贴板
              echo -n "$selection" | fish_clipboard_copy

              # 2. 执行删除选区
              # 优先使用 kill-selection，如果失败则尝试删除
              if not commandline -f kill-selection
                  commandline -f backward-kill-word
              end

              # 3. 核心修正：显式取消标记状态，防止下次输入或移动时还带着选区
              commandline -f end-selection
          else
              # 4. 如果没有选区，正常删除单词
              commandline -f backward-kill-word
          end

          # 5. 强制刷新界面
          commandline -f repaint
      end
      bind \cw x_kill_region_smart

      function x_smart_delete
          set -l selection (commandline -s)
          if test -n "$selection"
              # 如果有选区，删除选区内容
              commandline -f kill-selection
              # 显式退出标记模式
              commandline -f end-selection
          else
              # 否则，执行正常的向后删除一个字符
              commandline -f backward-delete-char
          end
          commandline -f repaint
      end
      bind \x7f x_smart_delete
      # Alacritty & Zellij 自动挂载
      if set -q ALACRITTY_LOG
        if not set -q ZELLIJ
          zellij attach -c
        end
      end
    '';
  };
}
