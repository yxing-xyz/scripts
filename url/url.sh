#!/bin/bash
read -d '' content <<EOF
$(date +"%Y-%m-%d %H:%M:%S")

EOF

echo "$content" >./url.txt
echo >>./url.txt

tee >>./url.txt <<'EOF'
# 1. 创建 Docker 卷
docker volume create home

# 2. 启动开发环境容器 (建议在此处挂载 Socket)
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
    registry.cn-hangzhou.aliyuncs.com/yxing-xyz/linux:arch \
    bash -c "mkdir -p /run/sshd && /usr/sbin/sshd -D"

# 3. root用户配置nix
mkdir -p /nix
chown x:x /nix
mkdir -p /etc/nix
su - x -c "curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install | sh -s -- --no-daemon"
tee >>/etc/nix/nix.conf <<EOF_NIX
accept-flake-config = true
experimental-features = nix-command flakes
max-jobs = auto
EOF_NIX
chmod 777 -R /opt

# 普通用户执行
git clone git@gitee.com:yxing-xyz/scripts.git /opt/scripts
source /home/x/.nix-profile/etc/profile.d/nix.sh
cd /opt/scripts/nixos
home-manager switch --flake .#code
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
