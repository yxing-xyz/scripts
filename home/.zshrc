typeset -A ZINIT
ZINIT[NO_ALIASES]=1
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [ ! -d "$ZINIT_HOME" ]; then
    mkdir -p "$(dirname $ZINIT_HOME)"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"
TRZSZ_ENABLE=trzsz
OMZTHEME=OMZT::robbyrussell
# OMZTHEME=OMZT::eastwood
# OMZTHEME=OMZT::garyblessington
# OMZTHEME=OMZT::imajes

HISTSIZE="1000000"
SAVEHIST="1000000"
HISTFILE="$HOME/.zsh_history"
setopt HIST_FCNTL_LOCK
# Enabled history options
enabled_opts=(
  HIST_EXPIRE_DUPS_FIRST HIST_IGNORE_ALL_DUPS HIST_IGNORE_DUPS HIST_IGNORE_SPACE
  SHARE_HISTORY
)
for opt in "${enabled_opts[@]}"; do
  setopt "$opt"
done
unset opt enabled_opts
# Disabled history options
disabled_opts=(
  APPEND_HISTORY EXTENDED_HISTORY HIST_FIND_NO_DUPS HIST_SAVE_NO_DUPS
)
for opt in "${disabled_opts[@]}"; do
  unsetopt "$opt"
done
unset opt disabled_opts

# # 快速跳转
zinit snippet OMZ::plugins/svn # svn
zinit snippet OMZ::lib/git.zsh # git
zinit snippet OMZ::lib/async_prompt.zsh
zinit snippet OMZ::lib/history.zsh
zinit snippet OMZ::lib/key-bindings.zsh
zinit snippet OMZ::lib/clipboard.zsh # 剪剪切板

zinit snippet OMZ::plugins/colored-man-pages/colored-man-pages.plugin.zsh
zinit snippet OMZ::plugins/extract # 后缀解压

zinit snippet OMZ::lib/completion.zsh

# # 快速语法高亮
zinit wait lucid for \
    atinit"ZINIT[COMPINIT_OPTS]=-C; zicompinit; zicdreplay" \
    zdharma-continuum/fast-syntax-highlighting \
    blockf \
    zsh-users/zsh-completions \
    atload"!_zsh_autosuggest_start" \
    zsh-users/zsh-autosuggestions

zinit snippet OMZ::lib/theme-and-appearance.zsh
zinit snippet ${OMZTHEME}
zinit wait lucid for \
  Aloxaf/fzf-tab
zstyle ':fzf-tab:complete:*:*' fzf-preview \
    'if [ -d $realpath ]; then \
        lsd -A --tree --color=always $realpath | head -200; \
     else \
        bat --style=numbers --color=always --line-range :500 --wrap character --terminal-width $FZF_PREVIEW_COLUMNS $realpath; \
     fi'
zstyle ':fzf-tab:complete:(-command-|-parameter-|-brace-parameter-):*' fzf-preview 'echo ${(P)word}'
export COLORTERM=truecolor
# 2. 设置 环境变量 (使用 export)
export FZF_DEFAULT_OPTS="--no-mouse --height 70% --reverse --multi --inline-info \
--preview 'if [ -d {} ]; then lsd --tree --depth 5 --color always {}; else bat --style=numbers --color=always --line-range :1000 {} 2>/dev/null; fi' \
--bind 'ctrl-/:toggle-preview'"
export FZF_CTRL_T_COMMAND="fd --hidden --follow --exclude .git 2> /dev/null"
export FZF_ALT_C_COMMAND="fd -t d --hidden --follow 2> /dev/null"
# emacs
export EDITOR='vim'
export RUSTUP_UPDATE_ROOT=https://mirrors.aliyun.com/rustup/rustup
export RUSTUP_DIST_SERVER=https://mirrors.aliyun.com/rustup
# vcpkg
export VCPKG_ROOT=$HOME/.local/share/vcpkg
# PATH
case ":${PATH}:" in
*:"$HOME/.cargo/bin":*) ;;
*)
    if [[ "${OSTYPE}" == darwin* ]]; then
        export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.aliyun.com/git/homebrew/brew.git"
        export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.aliyun.com/git/homebrew/homebrew-core.git"
        export HOMEBREW_INSTALL_FROM_API=1
        export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.aliyun.com/git/homebrew/brew.git"
        eval "$(/opt/homebrew/bin/brew shellenv)"
        export DOCKER_HOST=unix:///Users/x/.docker/run/docker.sock
    fi
    export PATH=$HOME/.local/bin:$PATH
    export PATH=$HOME/.cargo/bin:$PATH
    export PATH=$HOME/go/bin:$PATH
    ;;
esac

cheat.sh() {
    curl -L cheat.sh/$1
}
shutdownAfter() {
    while [ true ]; do
        pgrep $1 >/dev/null 2>&1
        if (($? != 0)); then
            break
        fi
        sleep 10
    done
    shutdown -h now
}
setProxy() {
    case $1 in
    start)
        PROXY_SERVER="127.0.0.1:10808" # define your proxy server here
        echo "setting proxy..."
        export http_proxy="http://$PROXY_SERVER"
        export https_proxy="http://$PROXY_SERVER"
        export ftp_proxy="ftp://$PROXY_SERVER"
        export HTTP_PROXY=$http_proxy
        export HTTPS_PROXY=$https_proxy
        export FTP_PROXY=$ftp_proxy
        export all_proxy=$http_proxy
        export NO_PROXY=localhost,192.168.*,10.*,127.0.*
        ;;
    stop)
        echo "stopping proxy..."
        unset http_proxy
        unset https_proxy
        unset ftp_proxy
        unset HTTP_PROXY
        unset HTTPS_PROXY
        unset FTP_PROXY
        unset all_proxy
        unset NO_PROXY
        ;;
    status)
        echo "http_proxy=$http_proxy"
        echo "HTTP_PROXY=$HTTP_PROXY"
        echo "https_proxy=$https_proxy"
        echo "HTTPS_PROXY=$HTTPS_PROXY"
        echo "ftp_proxy=$ftp_proxy"
        echo "FTP_PROXY=$FTP_PROXY"
        echo "all_proxy=$all_proxy"
        echo "NO_PROXY=$NO_PROXY"
        ;;
    esac
}

# 按键
if [[ -n $DISPLAY ]] || [[ "${OSTYPE}" == darwin* ]]; then
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

    bindkey -e '\ew' x-copy-region-as-kill
    bindkey -e '^W' x-kill-region
    bindkey -e '^Y' x-yank
    bindkey -e '\C-k' x-kill-line
fi
x-input-current-path() {
    CUTBUFFER=$(pwd)
    zle yank
}
zle -N x-input-current-path
bindkey -e '^[\' x-input-current-path

x-input-empty-dir() {
    CUTBUFFER='rm -rf ./*'
    zle yank
}
zle -N x-input-empty-dir
bindkey -e '^[`' x-input-empty-dir

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

bindkey -e '^?' x-backward-delete-char
bindkey -e '^[[3~' x-delete-char
bindkey -e '^x^e' edit-command-line

# 还原emacs快捷键
bindkey -e '\el' down-case-word
bindkey -s '\e^M' 'ls -lh\n'
bindkey -e '\ec' capitalize-word
bindkey -e '^T' transpose-chars

source <(fzf --zsh)
# 3. 快捷键绑定 (使用 bindkey)
# 注意：Zsh 中 Alt(Option) 键通常映射为 \e (Escape)
# 取消默认绑定 (如果需要完全自定义)
bindkey -r '^T'
bindkey -r '\ec'
bindkey -r '^R'
# 重新绑定 Alt+9 (对应 \e9) 为文件搜索
bindkey '\e9' fzf-file-widget
# 重新绑定 Alt+0 (对应 \e0) 为目录搜索
bindkey '\e0' fzf-cd-widget
# 重新绑定 Ctrl+r 为历史搜索，并临时禁用预览
fzf-history-no-preview() {
  local LBUFFER_TEMP=$LBUFFER
  # 临时修改变量仅对本次执行有效
  FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --no-preview" fzf-history-widget
}
zle -N fzf-history-no-preview
bindkey '^R' fzf-history-no-preview

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
# alias
alias -- ..='cd ..'
alias -- ...='cd ../..'
alias -- .3='cd ../../..'
alias -- .4='cd ../../../..'
alias -- .5='cd ../../../../..'
alias -- bj='sshuttle --dns -vr root@60.205.202.6 10.0.0.0/8 172.16.0.0/12 --ssh-cmd "ssh -i $HOME/.ssh/品牌中心.key"'
alias -- c=clear
alias -- cat=bat
alias -- diff='difft --display inline'
alias -- docker='TERM=xterm-256color $TRZSZ_ENABLE docker'
alias -- eq='emacs -nw -q'
alias -- er='emacsclient -r'
alias -- et='emacsclient -t'
alias -- hz='sshuttle --dns -vr root@112.124.55.199 10.0.0.0/8 192.168.0.0/16 --ssh-cmd "ssh -i $HOME/.ssh/品牌中心.key"'
alias -- k9s='$TRZSZ_ENABLE k9s'
alias -- la='lsd -A'
alias -- ll='lsd -l'
alias -- lla='lsd -lA'
alias -- llt='lsd -l --tree'
alias -- ls=lsd
alias -- lt='lsd --tree'
alias -- lzd='$TRZSZ_ENABLE lazydocker'
alias -- lzg=lazygit
alias -- mkdir='mkdir -p'
alias -- rm=trash-put
alias -- ssh='TERM=xterm-256color $TRZSZ_ENABLE ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
alias -- tree='ls --tree'
alias -- yy=yazi
alias -- yz='zoxide query -i | xargs -r yazi'
# Alacritty & Zellij 自动挂载
if [ ! -z "${ALACRITTY_LOG+x}" ]; then
  if [[ -z "$ZELLIJ" ]]; then
    zellij attach -c
  fi
fi
# eval "$(vfox activate zsh)"
eval "$(zoxide init zsh)"
