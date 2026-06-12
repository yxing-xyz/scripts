#!/bin/bash
read -d '' content <<EOF
$(date +"%Y-%m-%d %H:%M:%S")

EOF

echo "$content" >./url.txt
echo >>./url.txt

tee >>./url.txt <<'EOF'
# 1. 创建 Docker 卷
docker volume create nix
docker volume create home

# 2. 启动 Nix Daemon 容器 (带初始化逻辑)
docker run -dit \
    --name nix \
    --hostname code \
    --restart always \
    --privileged \
    --pull always \
    --platform linux/amd64 \
    -v nix:/nix \
    nixpkgs/nix-flakes bash -c "
        if [ ! -f /etc/nix/.initialized ]; then
            rm -f /etc/nix/nix.conf
            echo 'experimental-features = nix-command flakes' >> /etc/nix/nix.conf
            echo 'accept-flake-config = true' >> /etc/nix/nix.conf
            echo 'trusted-users = *' >> /etc/nix/nix.conf
            touch /etc/nix/.initialized
            echo 'Nix initialized successfully.'
        fi
        nix-daemon
    "

# 3. 启动开发环境容器 (建议在此处挂载 Socket)
docker run -dit \
    --name code \
    --hostname code \
    --restart always \
    --privileged \
    --pull always \
    --platform linux/amd64 \
    -p 22:22 \
    -e DOCKER_HOST=tcp://host.docker.internal:2375 \
    -v home:/home \
    -v nix:/nix \
    registry.cn-hangzhou.aliyuncs.com/yxing-xyz/linux:arch \
    bash -c "mkdir -p /run/sshd && /usr/sbin/sshd -D"
EOF

echo >>./url.txt
RepoLatestRelease() {
    owner=$1
    repo=$2
    list=$(curl -s https://api.github.com/repos/${owner}/${repo}/releases/latest | grep browser_download_url)
    array=($(echo "$list" | grep -Eo "\"https://.+\""))
    for element in ${array[@]}; do
        element=${element:1}
        element=${element%?}
        echo "$element"
    done
}

githubReleaseURL() {
    owner=$1
    repo=$2
    filepath="${owner}-${repo}.txt"
    content="$(RepoLatestRelease "${owner}" "${repo}" )"
    echo "$content" >> "$filepath"
    printf "%s\n\n" "$filepath" >> url.txt
}
githubReleaseURL yxing-xyz scripts
githubReleaseURL trzsz trzsz-go
githubReleaseURL derailed k9s
githubReleaseURL jesseduffield lazygit
githubReleaseURL tsenart vegeta
githubReleaseURL FiloSottile mkcert
githubReleaseURL version-fox vfox
githubReleaseURL jesseduffield lazydocker
githubReleaseURL v2fly v2ray-core
githubReleaseURL v2rayA v2rayA
githubReleaseURL localsend localsend
githubReleaseURL FelisCatus SwitchyOmega
githubReleaseURL wagoodman dive
githubReleaseURL iyear tdl
