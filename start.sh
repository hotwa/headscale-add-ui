#!/bin/bash

# 激活虚拟环境
source /app/.venv/bin/activate

# 在后台启动 headscale 服务，但不使用 & 放入后台，而是让其在前台运行
headscale serve &

# 在后台启动 Headscale-WebUI
gunicorn -w 4 -b 0.0.0.0:5000 server:app &

# 等待任何进程退出
wait -n

# 然后终止其他进程
kill -TERM $!
