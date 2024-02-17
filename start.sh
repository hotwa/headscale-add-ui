#!/bin/bash

# 激活虚拟环境
. /app/.venv/bin/activate

# 在后台启动 Headscale-WebUI
gunicorn -w 1 -b 0.0.0.0:5000 server:app &

# 等待任何进程退出
wait -n

# 然后终止其他进程
kill -TERM $!
