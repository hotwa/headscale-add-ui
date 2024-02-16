# 基于Debian 12构建镜像
FROM debian:12

# 接受HEADSCALE_DEB作为构建参数
ARG HEADSCALE_DEB

# 安装必要的软件包
RUN apt-get update && \
    apt-get install -y nginx wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY ${HEADSCALE_DEB} headscale.deb
RUN dpkg -i headscale.deb || apt-get -f install && \
    rm -f headscale.deb

# 复制Headscale UI源码到指定目录
COPY headscale-ui/ /var/www/web/

# Nginx配置，假设您已经根据需要调整了Nginx配置
COPY nginx-headscale.conf /etc/nginx/sites-available/default

# 暴露必要的端口
EXPOSE 80 443 8080

# 启动Nginx和Headscale服务
CMD ["sh", "-c", "nginx -g 'daemon off;' & headscale serve"]
