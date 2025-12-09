#!/bin/bash
# 一键安装 X-UI (amd64) + 注册 x‑ui 命令 + systemd 服务 + 第一次配置
set -e

# 变量
XUI_VER="v2.3.9"  # ← 可改为你想固定的版本
ARCHIVE_URL="https://github.com/MHSanaei/3x-ui/releases/download/${XUI_VER}/x-ui-linux-amd64.tar.gz"
INSTALL_DIR="/usr/local/x-ui"
BIN_PATH="$INSTALL_DIR/x-ui"
SERVICE_PATH="/etc/systemd/system/x-ui.service"
WRAPPER="/usr/bin/x-ui"

# 安装必备工具
apt update
apt install -y wget curl tar

# 停止旧服务（如果有）
systemctl stop x-ui >/dev/null 2>&1 || true
pkill -f x-ui >/dev/null 2>&1 || true

# 创建目录并下载
mkdir -p ${INSTALL_DIR}
cd ${INSTALL_DIR}
wget -O x-ui-linux-amd64.tar.gz "${ARCHIVE_URL}"
tar -xzf x-ui-linux-amd64.tar.gz
chmod +x x-ui

# 下载官方菜单脚本
wget -O ${WRAPPER} https://raw.githubusercontent.com/MHSanaei/3x-ui/main/x-ui.sh
chmod +x ${WRAPPER}

# 创建 systemd 服务
cat > ${SERVICE_PATH} <<EOF
[Unit]
Description=X-UI Service
After=network.target

[Service]
Type=simple
WorkingDirectory=${INSTALL_DIR}
ExecStart=${BIN_PATH}
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable x-ui

echo "################################################"
echo "Now run 'x-ui' to configure panel port, username and password."
echo "After configuration, run 'systemctl start x-ui' to start service."
echo "################################################"

# 不自动启动，交由用户通过 x-ui 菜单完成设置和启动
