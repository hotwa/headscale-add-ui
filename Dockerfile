# 基于Debian 12构建镜像
# 使用官方Python镜像作为构建的基础
FROM python:3.11-slim as builder

# 设置工作目录
WORKDIR /app

# 安装系统依赖、Rust 编译器和 Poetry
RUN apt-get update && apt-get install -y curl gcc libffi-dev libssl-dev git cargo && \
    pip install poetry && \
    poetry config virtualenvs.create false && \
    rm -rf /var/lib/apt/lists/*


# 复制项目文件
COPY headscale-webui/src/ /app/

# 安装 Python 依赖
RUN poetry install --no-dev

# 使用多阶段构建，减少最终镜像的大小
FROM python:3.11-slim

# 复制从上一个阶段构建的虚拟环境
COPY --from=builder /app /app
WORKDIR /app

# 设置环境变量
ENV TZ="UTC" \
    COLOR="blue-grey" \
    HS_SERVER="http://localhost:8080" \
    KEY="GenerateYourOwnRandomKey" \
    SCRIPT_NAME="/admin" \
    DATA_DIRECTORY="/data" \
    DOMAIN_NAME="http://localhost:8080" \
    AUTH_TYPE="basic" \
    LOG_LEVEL="Info" \
    BASIC_AUTH_USER="admin" \
    BASIC_AUTH_PASS="admin" \
    OIDC_AUTH_URL="https://localhost:8080" \
    OIDC_CLIENT_ID="Headscale-WebUI" \
    OIDC_CLIENT_SECRET="secret"

# 接受HEADSCALE_DEB作为构建参数
ARG HEADSCALE_DEB

# 安装必要的软件包
RUN apt-get update && \
    apt-get install -y dpkg wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY ${HEADSCALE_DEB} headscale.deb
RUN dpkg -i headscale.deb || apt-get -f install && \
    rm -f headscale.deb

VOLUME /etc/headscale
VOLUME /data

# 暴露必要的端口
EXPOSE 5000/tcp 8080/tcp

# 启动headscale-webui和Headscale服务
COPY start.sh /app/
RUN chmod +x /app/start.sh

CMD ["/app/start.sh"]
