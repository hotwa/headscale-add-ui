#!/bin/bash

# 启动需要 root 权限的服务
headscale serve &

# 切换回 uid 为 1000 用户执行 CMD
exec gosu 1000 "$@"
