#!/bin/bash

# 启动需要 root 权限的服务
headscale serve &

# 切换回 appuser 用户执行 CMD
exec gosu appuser "$@"
