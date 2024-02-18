#!/bin/bash

# Docker Compose 安装路径
DOCKER_COMPOSE_PATH="/usr/local/bin/docker-compose"

install_docker() {
    echo "正在检查 Docker 是否已安装..."
    if ! [ -x "$(command -v docker)" ]; then
        echo "Docker 未安装。正在安装 Docker..."
        curl -fsSL https://get.docker.com -o get-docker.sh
        sh get-docker.sh
        echo "Docker 已安装。"
    else
        echo "Docker 已安装。"
    fi
}

install_docker_compose() {
    install_docker
    echo "正在安装 Docker Compose..."

    # 使用 GitHub API 获取最新版本
    LATEST_RELEASE=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | jq -r .tag_name)
    if [ -z "$LATEST_RELEASE" ]; then
        echo "无法获取 Docker Compose 的最新版本。"
        exit 1
    fi

    # 更新 Docker Compose 安装 URL 以使用最新版本
    DOCKER_COMPOSE_URL="https://ghproxy.dockless.eu.org/https://github.com/docker/compose/releases/download/${LATEST_RELEASE}/docker-compose-$(uname -s)-$(uname -m)"

    sudo curl -L $DOCKER_COMPOSE_URL -o $DOCKER_COMPOSE_PATH
    sudo chmod +x $DOCKER_COMPOSE_PATH
    echo "Docker Compose ${LATEST_RELEASE} 已安装。"
}

uninstall_docker_compose() {
    echo "正在卸载 Docker Compose..."
    rm -f $DOCKER_COMPOSE_PATH
    echo "Docker Compose 已卸载。"
}

echo "选择操作："
echo "1) 安装 Docker Compose"
echo "2) 卸载 Docker Compose"
echo "3) 退出"
read -p "输入选择（1-3）：" choice

case $choice in
    1) install_docker_compose ;;
    2) uninstall_docker_compose ;;
    3) exit 0 ;;
    *) echo "无效输入。" ;;
esac

