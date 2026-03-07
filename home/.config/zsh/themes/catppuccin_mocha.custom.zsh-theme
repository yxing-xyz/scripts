# 开启颜色支持
autoload -U colors && colors

# 简单的提示符设计：[目录] ➜
# %F{...} 对应 Catppuccin 颜色：#89b4fa (Blue), #a6e3a1 (Green), #fab387 (Peach)
PROMPT='%F{#89b4fa}%~%f %F{#a6e3a1}➜%f '

# 右侧提示符：显示执行状态和时间
RPROMPT='%(?.%F{#a6e3a1}✔.%F{#f38ba8}✘)%f %F{#6c7086}%T%f'

# --- 配合你刚才提供的语法高亮 ---
# 请确保你已经安装了 zsh-syntax-highlighting
# 并在 .zshrc 中 source 了它
# 然后紧跟着应用你提供的那段 ZSH_HIGHLIGHT_STYLES 配置
