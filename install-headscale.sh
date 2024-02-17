#!/bin/bash

# 检查是否传入了预发布版本的参数
PRE_RELEASE=$1

# 确定系统架构
ARCH=$(uname -m)
case $ARCH in
    x86_64)
        DEB_ARCH="amd64"
        ;;
    aarch64)
        DEB_ARCH="arm64"
        ;;
    i386|i686)
        DEB_ARCH="386"
        ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

# 设置 GitHub API URL
API_URL="https://api.github.com/repos/juanfont/headscale/releases"

# 根据参数决定是获取预发布版本还是最新稳定版本的信息
if [ "$PRE_RELEASE" == "prerelease" ]; then
    # 获取预发布版本的 tag_name 和 .deb 包的下载链接
    VERSION=$(curl -s "$API_URL" | jq -r '[.[] | select(.prerelease == true)][0].tag_name')
    URL=$(curl -s "$API_URL" | jq -r --arg DEB_ARCH "$DEB_ARCH" '[.[] | select(.prerelease == true)][0].assets[] | select(.name | test("headscale_.*_" + $DEB_ARCH + "\\.deb")) | .browser_download_url')
else
    # 获取最新稳定版本的 tag_name 和 .deb 包的下载链接
    VERSION=$(curl -s "$API_URL/latest" | jq -r '.tag_name')
    URL=$(curl -s "$API_URL/latest" | jq -r --arg DEB_ARCH "$DEB_ARCH" '.assets[] | select(.name | test("headscale_.*_" + $DEB_ARCH + "\\.deb")) | .browser_download_url')
fi

# 输出版本和下载链接信息（可选）
echo "Version: $VERSION"
echo "Downloading .deb package from: $URL"

# 下载并安装 .deb 包
wget -O headscale.deb "$URL"
dpkg -i headscale.deb || apt-get -f install -y

# 清理下载的 .deb 包
# rm -f headscale.deb
