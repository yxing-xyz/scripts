#!/bin/bash
set -e

# ANSI color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 获取脚本所在目录并计算home_dir
home_dir=$(dirname "$(readlink -f "$0")")/home

# 定义一个函数来进行目录或文件链接，并根据情况输出不同颜色的消息
create_symlink() {
    local target="$1"
    local link_name="$2"

    if [ ! -e "$link_name" ]; then
        if ln -sf "$target" "$link_name"; then
            echo -e "${GREEN}Created symlink for $link_name${NC}"
        else
            echo -e "${RED}Failed to create symlink for $link_name${NC}"
        fi
    else
        if [ -h "$link_name" ]; then
            echo -e "${GREEN}$link_name already exists, skipping...${NC}"
        else
            echo -e "${RED}$link_name already exists, skipping...${NC}"
        fi
    fi
}

# 手动映射
declare -A link_map=(
    ["${home_dir}/.ssh"]="${HOME}/.ssh"
    ["${home_dir}/.emacs.d"]="${HOME}/.emacs.d"
    ["${home_dir}/.cargo"]="${HOME}/.cargo"
    ["${home_dir}/.Xresources"]="${HOME}/.Xresources"
    ["${home_dir}/.zshrc"]="${HOME}/.zshrc"
    ["${home_dir}/.gitconfig"]="${HOME}/.gitconfig"
    ["${home_dir}/.npmrc"]="${HOME}/.npmrc"
    ["${home_dir}/.gtkrc-2.0"]="${HOME}/.gtkrc-2.0"
)

for target in "${!link_map[@]}"; do
    create_symlink "$target" "${link_map[$target]}"
done

# 处理.config
contents=("$home_dir/.config"/*)
for item in "${contents[@]}"; do
    create_symlink "$item" "${HOME}/.config/$(basename "$item")"
done

# 处理.local
contents=("$home_dir/.local"/*)
for item in "${contents[@]}"; do
    if [[ "$(basename $item)" != "share" ]]; then
        create_symlink "$item" "${HOME}/.local/$(basename "$item")"
    fi
done

# 处理.local/share
contents=("$home_dir/.local/share"/*)
mkdir -p ${HOME}/.local/share
for item in "${contents[@]}"; do
    create_symlink "$item" "${HOME}/.local/share/$(basename "$item")"
done
