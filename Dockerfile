# 基于Debian 12构建镜像
# 使用官方Python镜像作为构建的基础
FROM python:3.11-slim as builder

# 设置工作目录
WORKDIR /app

# 安装系统依赖、Rust 编译器
# 由于安装系统级别的软件包需要root权限，这一步使用root用户
RUN apt-get update && \
    apt-get install -y --no-install-recommends wget curl gcc libffi-dev libssl-dev git rustc pkg-config && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 创建非root用户并切换到该用户
# 注意，这里我们创建了一个uid为1000的用户，与大多数Linux系统的默认非root用户uid一致
RUN groupadd -g 1000 appuser && \
useradd -m -u 1000 -g appuser -s /bin/bash appuser
USER appuser

# 安装Poetry - 作为非root用户
RUN pip install --user poetry && \
    poetry config virtualenvs.create true && \
    poetry install --no-dev 

# 复制项目文件
COPY --chown=appuser:appuser headscale-webui/src/ /app/

# 使用 Poetry 创建虚拟环境并安装依赖
# 注意，这里我们使用了`--user`选项安装Poetry，因此需要调整PATH以使用局部安装的Poetry
ENV PATH="/home/appuser/.local/bin:$PATH"
RUN poetry config virtualenvs.create true && \
    poetry install --no-dev

# 找到并复制虚拟环境到/app/.venv，这一步可能需要根据实际生成的虚拟环境路径进行调整
# 注意，Poetry默认在/home/appuser/.cache/pypoetry/virtualenvs中创建虚拟环境
RUN cp -r $(poetry env info -p) /app/.venv

# 使用多阶段构建，减少最终镜像的大小
FROM python:3.11-slim

# 创建非root用户并切换到该用户
RUN groupadd -g 1000 appuser && \
useradd -m -u 1000 -g appuser -s /bin/bash appuser

# 接受HEADSCALE_DEB作为构建参数
ARG HEADSCALE_DEB

# 安装必要的软件包和Headscale，然后清理缓存
RUN apt-get update && apt-get install -y dpkg && \
    dpkg -i ${HEADSCALE_DEB} || apt-get -f install && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /${HEADSCALE_DEB}

USER appuser

WORKDIR /app

# 复制从上一个阶段构建的虚拟环境及应用代码
COPY --from=builder --chown=appuser:appuser /app /app

# 确保使用虚拟环境
ENV PATH="/app/.venv/bin:$PATH"

# 后续的RUN、CMD或ENTRYPOINT命令都将以非root用户运行

# 定义运行时需要的环境变量
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
