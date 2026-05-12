#!/bin/bash

PUBLIC_IP=$(curl -s --max-time 5 ipv4.icanhazip.com 2>/dev/null)
if [ -z "$PUBLIC_IP" ]; then
    PUBLIC_IP=$(curl -s --max-time 5 ifconfig.me 2>/dev/null)
fi
[ -z "$PUBLIC_IP" ] && PUBLIC_IP="无法获取"

if command -v sshd &> /dev/null; then
    SSH_PORT=$(sshd -T 2>/dev/null | grep -i ^port | awk '{print $2}')
    [ -z "$SSH_PORT" ] && SSH_PORT="22 (默认)"
else
    SSH_PORT="未安装 SSH 服务"
fi

CURRENT_USER=$(whoami)

CPU_CORES=$(nproc)

MEM_TOTAL_RAW=$(free -h | awk '/^Mem:/ {print $2}')
MEM_TOTAL=$(echo "$MEM_TOTAL_RAW" | sed 's/Gi/G/g' | sed 's/Mi/M/g')

if command -v lsblk &> /dev/null; then
    DISK_TOTAL=$(lsblk -b -d -n -o SIZE 2>/dev/null | awk '{sum+=$1} END {print sum}')
    if [ -n "$DISK_TOTAL" ] && [ "$DISK_TOTAL" -gt 0 ]; then
        DISK_TOTAL=$(numfmt --to=iec $DISK_TOTAL 2>/dev/null | sed 's/Gi/G/g' | sed 's/Mi/M/g' || echo "${DISK_TOTAL} B")
    else
        DISK_TOTAL=$(df -h --total -x tmpfs -x devtmpfs 2>/dev/null | awk '/^total/ {print $2}')
    fi
else
    DISK_TOTAL=$(df -h --total -x tmpfs -x devtmpfs 2>/dev/null | awk '/^total/ {print $2}')
fi
DISK_TOTAL=$(echo "$DISK_TOTAL" | sed 's/Gi/G/g' | sed 's/Mi/M/g' | sed 's/Ti/T/g')
[ -z "$DISK_TOTAL" ] && DISK_TOTAL="无法获取"

RAW_CPU_MODEL=$(lscpu 2>/dev/null | grep "Model name" | cut -d':' -f2 | sed 's/^[ \t]*//')
if [ -z "$RAW_CPU_MODEL" ]; then
    RAW_CPU_MODEL=$(grep "model name" /proc/cpuinfo 2>/dev/null | head -1 | cut -d':' -f2 | sed 's/^[ \t]*//')
fi

CPU_MODEL=""
if echo "$RAW_CPU_MODEL" | grep -qi "E5-.*v4"; then
    CPU_MODEL="E5 v4"
elif echo "$RAW_CPU_MODEL" | grep -qi "8255C"; then
    CPU_PHYSICAL=$(lscpu 2>/dev/null | grep "^Socket(s):" | awk '{print $2}')
    if [ -z "$CPU_PHYSICAL" ]; then
        CPU_PHYSICAL=$(grep "physical id" /proc/cpuinfo 2>/dev/null | sort -u | wc -l)
    fi
    [ -z "$CPU_PHYSICAL" ] && CPU_PHYSICAL=1
    CPU_MODEL="8255C * ${CPU_PHYSICAL}（${CPU_CORES}C）"
elif [ -n "$RAW_CPU_MODEL" ]; then
    CPU_MODEL="$RAW_CPU_MODEL"
else
    CPU_MODEL="未知"
fi

KERNEL_VER=$(uname -r)

if [ -f /etc/os-release ]; then
    OS_NAME=$(grep '^PRETTY_NAME=' /etc/os-release | cut -d'"' -f2)
elif [ -f /etc/redhat-release ]; then
    OS_NAME=$(cat /etc/redhat-release | sed 's/ release //')
elif [ -f /etc/debian_version ]; then
    OS_NAME="Debian $(cat /etc/debian_version)"
else
    OS_NAME=$(uname -o)
fi

echo "公网IP：${PUBLIC_IP}"
echo "SSH端口：${SSH_PORT}"
echo "当前用户：${CURRENT_USER}"
echo "CPU核心数：${CPU_CORES}C"
echo "内存总量：${MEM_TOTAL}"
echo "磁盘总量：${DISK_TOTAL}"
echo "CPU型号：${CPU_MODEL}"
echo "内核版本：${KERNEL_VER}"
echo "操作系统：${OS_NAME}"
