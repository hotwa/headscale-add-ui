# 基于Debian 12构建镜像
# 使用官方Python镜像作为构建的基础
FROM python:3.11-slim as builder

# 设置工作目录
WORKDIR /app
# 复制项目文件
COPY headscale-webui/src/ /app/
# 安装系统依赖、Rust 编译器
# 由于安装系统级别的软件包需要root权限，这一步使用root用户
RUN apt-get update && \
    apt-get install -y --no-install-recommends wget curl gcc libffi-dev libssl-dev git rustc pkg-config && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN pip install poetry && \
    poetry config virtualenvs.create true && \
    poetry install --no-dev && \
    cp -r $(poetry env info -p) /app/.venv

# 第二阶段构建
FROM python:3.11-slim

# 接受HEADSCALE_DEB作为构建参数
ARG HEADSCALE_DEB

# 创建并切换到非root用户
# 安装必要的软件包和Headscale，然后清理缓存
# 将安装步骤与清理步骤合并为一个 RUN 命令以减少镜像层数
RUN groupadd -g 1000 appuser && \
    useradd -m -u 1000 -g appuser -s /bin/bash appuser && \
    apt-get update && apt-get install -y dpkg && \
    dpkg -i ${HEADSCALE_DEB} || apt-get -f install && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

USER appuser
WORKDIR /app

# 复制从上一个阶段构建的虚拟环境及应用代码
COPY --from=builder --chown=appuser:appuser /app /app

# 确保使用虚拟环境
# 定义运行时需要的环境变量
# 这一步将多个 ENV 指令合并成一个，以减少镜像层数
ENV PATH="/app/.venv/bin:$PATH" \
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
    OIDC_CLIENT_SECRET="secret"

VOLUME ["/etc/headscale", "/data"]

# 暴露必要的端口
EXPOSE 5000/tcp 8080/tcp

# 启动headscale-webui和Headscale服务
COPY --chown=appuser:appuser start.sh /app/
RUN chmod +x /app/start.sh

CMD ["/app/start.sh"]
