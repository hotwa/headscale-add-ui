#!/bin/bash
source /app/.venv/bin/activate

# 启动 headscale 服务
headscale serve &

# 启动 Headscale-WebUI
gunicorn -w 4 -b 0.0.0.0:5000 server:app

# 等待任何进程退出
wait -n

# 然后终止其他进程
kill -TERM $!
