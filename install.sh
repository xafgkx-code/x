#!/bin/bash

# ============================
# X-UI v2.3.9 一键安装脚本 (AFGK)
# ============================

set -e

# 配置
XUI_DIR="/usr/local/x-ui"
XUI_PORT=3030
XUI_USER="AFGK"
XUI_PASS="AFGK"
SERVICE_NAME="x-ui"
DOWNLOAD_URL="https://github.com/MHSanaei/3x-ui/releases/download/v2.3.9/x-ui-linux-amd64.tar.gz"

echo "========================================"
echo "     一键安装 X-UI v2.3.9"
echo "========================================"

# 安装依赖
apt update
apt install -y wget tar curl

# 创建目录
mkdir -p $XUI_DIR
cd $XUI_DIR

# 下载并解压
echo "下载 X-UI..."
wget -O x-ui-linux-amd64.tar.gz $DOWNLOAD_URL
tar -xzf x-ui-linux-amd64.tar.gz
chmod +x x-ui

# 配置面板端口和账号
cat > $XUI_DIR/config.yml <<EOF
panel:
  listen: 0.0.0.0:$XUI_PORT
  username: $XUI_USER
  password: $XUI_PASS
EOF

# 创建 systemd 服务
cat > /etc/systemd/system/$SERVICE_NAME.service <<EOF
[Unit]
Description=X-UI v2.3.9 Service
After=network.target

[Service]
Type=simple
WorkingDirectory=$XUI_DIR
ExecStart=$XUI_DIR/x-ui
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# 启动服务
systemctl daemon-reload
systemctl enable $SERVICE_NAME
systemctl start $SERVICE_NAME

echo "========================================"
echo "安装完成！"
echo "访问面板：http://$(curl -s ifconfig.me):$XUI_PORT"
echo "用户名：$XUI_USER  密码：$XUI_PASS"
echo "启动命令：systemctl start $SERVICE_NAME"
echo "停止命令：systemctl stop $SERVICE_NAME"
echo "重启命令：systemctl restart $SERVICE_NAME"
echo "========================================"
