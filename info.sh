#!/bin/bash
echo "CPU 核心数：$(nproc)"

echo "内存总量：$(free -h | awk '/^Mem:/ {print $2}')"

echo "磁盘总量：$(df -h --total | awk '/^total/ {print $2}')"

if [ -f /etc/os-release ]; then
    OS_NAME=$(grep '^PRETTY_NAME=' /etc/os-release | cut -d'"' -f2)
elif [ -f /etc/redhat-release ]; then
    OS_NAME=$(cat /etc/redhat-release | sed 's/ release //')
elif [ -f /etc/debian_version ]; then
    OS_NAME="Debian $(cat /etc/debian_version)"
else
    OS_NAME=$(uname -o)
fi
echo "操作系统：${OS_NAME}"

echo "内核版本：$(uname -r)"

if command -v sshd &> /dev/null; then
    SSH_PORT=$(sshd -T 2>/dev/null | grep -i ^port | awk '{print $2}')
    if [ -z "$SSH_PORT" ]; then
        SSH_PORT="22 (默认，无法读取配置)"
    fi
else
    SSH_PORT="未安装 SSH 服务"
fi
echo "SSH端口：${SSH_PORT}"