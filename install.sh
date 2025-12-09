#!/bin/bash
# 3X-UI v2.3.9 / v2.8.5 一键安装脚本（Linux 64位）
# 功能：
# 1. 安装 x-ui-linux-amd64.tar.gz
# 2. 自定义面板端口/用户名/密码
# 3. 注册 systemd 服务
# 4. 注册 x-ui 命令，支持菜单操作
# 5. 支持一键开启 BBR

set -e

# =========================
# 变量设置
# =========================
XUI_DIR="/usr/local/x-ui"
XUI_BIN="$XUI_DIR/x-ui"
XUI_SERVICE="$XUI_DIR/x-ui.service"
XUI_SH="/usr/bin/x-ui"
ARCHIVE_URL="https://github.com/MHSanaei/3x-ui/releases/download/v2.3.9/x-ui-linux-amd64.tar.gz"
MENU_SCRIPT_URL="https://raw.githubusercontent.com/MHSanaei/3x-ui/main/x-ui.sh"

# =========================
# 安装依赖
# =========================
echo "Installing dependencies..."
apt update
apt install -y wget curl tar tzdata

# =========================
# 停止旧版本
# =========================
if systemctl is-active --quiet x-ui; then
    echo "Stopping existing x-ui service..."
    systemctl stop x-ui
fi
pkill -f xray || true

# =========================
# 创建目录
# =========================
mkdir -p $XUI_DIR
cd $XUI_DIR

# =========================
# 下载 X-UI
# =========================
echo "Downloading x-ui..."
wget -O x-ui-linux-amd64.tar.gz $ARCHIVE_URL

echo "Extracting..."
tar -xzf x-ui-linux-amd64.tar.gz
chmod +x x-ui

# =========================
# 下载管理脚本
# =========================
wget -O $XUI_SH $MENU_SCRIPT_URL
chmod +x $XUI_SH

# =========================
# systemd 服务
# =========================
cat > /etc/systemd/system/x-ui.service <<EOF
[Unit]
Description=X-UI Service
After=network.target

[Service]
Type=simple
ExecStart=$XUI_DIR/x-ui
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF

# =========================
# 设置用户名/密码/端口
# =========================
read -p "Please set Panel Port (default 8080): " PANEL_PORT
PANEL_PORT=${PANEL_PORT:-8080}
read -p "Please set Username (default admin): " PANEL_USER
PANEL_USER=${PANEL_USER:-admin}
read -sp "Please set Password (default 123456): " PANEL_PASS
echo
PANEL_PASS=${PANEL_PASS:-123456}

$XUI_BIN setting -port $PANEL_PORT -username $PANEL_USER -password $PANEL_PASS

# =========================
# 启动服务
# =========================
systemctl daemon-reload
systemctl enable x-ui
systemctl start x-ui

# =========================
# 显示信息
# =========================
echo "========================================"
echo " X-UI installation completed!"
echo " Access URL: http://$(curl -s ifconfig.me):$PANEL_PORT"
echo " Username: $PANEL_USER"
echo " Password: $PANEL_PASS"
echo " Use 'x-ui' command to manage panel"
echo "========================================"

# =========================
# 提示开启 BBR
# =========================
echo "You can enable BBR using the menu:"
echo "x-ui -> 23. Enable BBR"
