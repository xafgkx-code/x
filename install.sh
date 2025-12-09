#!/bin/bash
# ============================
# X-UI v2.3.9 一键安装脚本
# 作者：AFGK
# 系统：Ubuntu 22.04 x64
# CPU 架构：amd64
# ============================

set -e

# 配置
XUI_VERSION="v2.3.9"
XUI_PORT=3030
XUI_USER="AFGK"
XUI_PASS="AFGK"
XUI_DIR="/usr/local/x-ui"
SERVICE_NAME="x-ui"
DOWNLOAD_URL="https://github.com/MHSanaei/3x-ui/releases/download/v2.3.9/x-ui-linux-amd64.tar.gz"

echo "========================================"
echo "       Installing X-UI $XUI_VERSION      "
echo "========================================"

# 安装依赖
apt update -y
apt install wget tar unzip curl socat -y

# 创建目录
mkdir -p $XUI_DIR

# 下载并解压
cd /tmp
wget -O x-ui-linux-amd64.tar.gz $DOWNLOAD_URL
tar -zxvf x-ui-linux-amd64.tar.gz -C $XUI_DIR

# 设置权限
chmod +x $XUI_DIR/x-ui

# 创建 systemd 服务
cat >/etc/systemd/system/$SERVICE_NAME.service <<EOF
[Unit]
Description=X-UI Panel Service
After=network.target

[Service]
Type=simple
ExecStart=$XUI_DIR/x-ui
Restart=on-failure
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

# 启动并设置开机自启
systemctl daemon-reload
systemctl enable $SERVICE_NAME
systemctl start $SERVICE_NAME

# 设置默认用户和端口
$XUI_DIR/x-ui setting -username $XUI_USER
$XUI_DIR/x-ui setting -password $XUI_PASS
$XUI_DIR/x-ui setting -port $XUI_PORT

echo "========================================"
echo "       X-UI $XUI_VERSION Installed      "
echo "Access Panel: http://$(curl -s ifconfig.me):$XUI_PORT"
echo "Username: $XUI_USER  Password: $XUI_PASS"
echo "Use 'x-ui' command to manage panel"
echo "========================================"
