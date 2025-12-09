#!/bin/bash

# ============================
# X-UI v2.3.9 一键安装脚本
# 作者：AFGk 专用脚本
# CPU 架构：amd64
# ============================

set -e

echo "========================================"
echo "     开始安装 X-UI v2.3.9 (amd64)"
echo "========================================"

# 下载
echo "[1/5] 下载文件..."
wget -O /root/x-ui-linux-amd64.tar.gz https://github.com/MHSanaei/3x-ui/releases/download/v2.3.9/x-ui-linux-amd64.tar.gz

# 解压
echo "[2/5] 解压文件..."
tar -xzvf /root/x-ui-linux-amd64.tar.gz -C /root/

# 移动到目录
echo "[3/5] 安装 X-UI 文件..."
mkdir -p /usr/local/x-ui
cp -r /root/x-ui/* /usr/local/x-ui/

# 安装 systemd 服务
echo "[4/5] 安装 systemd 服务..."
cp /usr/local/x-ui/x-ui.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable x-ui

# 启动服务
echo "[5/5] 启动 X-UI..."
systemctl restart x-ui

echo "========================================"
echo " X-UI v2.3.9 安装成功！！！"
echo "----------------------------------------"
echo " 状态查看: systemctl status x-ui"
echo " 默认面板端口: 54321"
echo " 如果无法访问，请检查：ufw 或 安全组"
echo "========================================"

