# 基于Debian 12构建镜像
# 使用官方Python镜像作为构建的基础
FROM python:3.11-slim as builder

# 设置工作目录
WORKDIR /app

ARG HEADSCALE_VERSION_TYPE

# 创建用户
RUN groupadd -g 1000 appuser && \
    useradd -m -u 1000 -g appuser -s /bin/bash appuser

# 复制安装脚本
COPY install-headscale.sh ./install-headscale.sh
# 安装必要的软件包和Headscale，然后清理缓存
RUN apt-get update && apt-get install -y dpkg jq wget curl && \
    chmod +x ./install-headscale.sh && \
    ./install-headscale.sh ${HEADSCALE_VERSION_TYPE} && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 复制项目文件
COPY --chown=appuser:appuser headscale-webui/src/ /app/

# 修改目录权限
RUN chown -R appuser:appuser /app && \
    chmod -R 755 /app

# 安装系统依赖、Rust 编译器
RUN apt-get update && apt-get install -y wget curl gcc libffi-dev libssl-dev git rustc pkg-config gosu && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*


ARG GIT_COMMIT_ARG="" \
   GIT_BRANCH_ARG="" \
   APP_VERSION_ARG="" \
   BUILD_DATE_ARG="" \
   HS_VERSION_ARG=""

USER appuser

# 确保使用虚拟环境
# 定义运行时需要的环境变量, headscale-webui定义的环境变量 https://github.com/iFargle/headscale-webui/blob/main/Dockerfile
# 这一步将多个 ENV 指令合并成一个，以减少镜像层数
ENV PATH="/app/.venv/bin:/home/appuser/.local/bin:$PATH" \
    TZ="UTC" \
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
    OIDC_CLIENT_SECRET="secret" \
    GIT_COMMIT=$GIT_COMMIT_ARG \
    GIT_BRANCH=$GIT_BRANCH_ARG \
    APP_VERSION=$APP_VERSION_ARG \
    BUILD_DATE=$BUILD_DATE_ARG \
    HS_VERSION=$HS_VERSION_ARG

# Poetry，然后安装项目依赖  /home/appuser/.cache/pypoetry/virtualenvs
RUN pip install --user poetry && \
    poetry config virtualenvs.create true && \
    poetry install --no-dev --no-root && \
    cp -r $(poetry env info -p) /app/.venv

VOLUME ["/etc/headscale", "/data"]

# 暴露必要的端口
EXPOSE 5000/tcp 8080/tcp

# 启动headscale-webui和Headscale服务
COPY --chown=appuser:appuser start.sh /app/
RUN chmod +x /app/start.sh

USER root
# 设置 ENTRYPOINT 脚本
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

CMD ["./start.sh"]
