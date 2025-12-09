#!/bin/bash
# ============================
# X-UI v2.3.9 一键安装脚本（清理旧版本 + 修正版）
# 作者：AFGK
# 系统：Ubuntu 20.04/22.04 x64
# CPU 架构：amd64
# ============================

set -e

XUI_VERSION="v2.3.9"
XUI_PORT=3030
XUI_USER="AFGK"
XUI_PASS="AFGK"
XUI_DIR="/usr/local/x-ui"
DOWNLOAD_URL="https://github.com/MHSanaei/3x-ui/releases/download/v2.3.9/x-ui-linux-amd64.tar.gz"

echo "========================================"
echo "       Installing X-UI $XUI_VERSION      "
echo "========================================"

# 安装依赖
apt update -y
apt install wget tar unzip curl socat -y

# 停止旧服务并删除旧文件
if systemctl is-active --quiet x-ui; then
    systemctl stop x-ui
fi
if systemctl is-enabled --quiet x-ui; then
    systemctl disable x-ui
fi
rm -f /etc/systemd/system/x-ui.service
rm -rf $XUI_DIR
rm -f /usr/local/bin/x-ui
systemctl daemon-reload

# 创建目录
mkdir -p $XUI_DIR

# 下载并解压
cd /tmp
wget -O x-ui-linux-amd64.tar.gz $DOWNLOAD_URL
tar -zxvf x-ui-linux-amd64.tar.gz -C $XUI_DIR

# 将实际可执行文件放到 /usr/local/bin
chmod +x $XUI_DIR/x-ui/x-ui
mv $XUI_DIR/x-ui/x-ui /usr/local/bin/x-ui

# 创建 systemd 服务
cat >/etc/systemd/system/x-ui.service <<EOF
[Unit]
Description=X-UI Panel Service
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/x-ui
Restart=on-failure
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

# 启动并设置开机自启
systemctl daemon-reload
systemctl enable x-ui
systemctl start x-ui

# 设置默认用户名、密码、端口
x-ui setting -username $XUI_USER
x-ui setting -password $XUI_PASS
x-ui setting -port $XUI_PORT

echo "========================================"
echo "       X-UI $XUI_VERSION Installed      "
echo "Access Panel: http://$(curl -s ifconfig.me):$XUI_PORT"
echo "Username: $XUI_USER  Password: $XUI_PASS"
echo "Use 'x-ui' command to manage panel"
echo "========================================"
