#!/bin/bash


# 启动需要 root 权限的服务，并将输出重定向到日志文件
headscale serve > /var/lib/headscale/logfile.log 2>&1 &

# 切换回 uid 为 1000 用户执行 CMD
exec gosu 1000 "$@"
