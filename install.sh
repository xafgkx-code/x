#!/bin/bash
# 3X-UI v2.3.9 一键安装脚本
set -e

echo "检测系统环境..."
OS=$(uname -s)
ARCH=$(uname -m)
echo "系统: $OS, 架构: $ARCH"

# 安装依赖
echo "安装依赖包..."
apt update
apt install -y curl wget tar

# 创建安装目录
mkdir -p /usr/local/x-ui
cd /usr/local/x-ui

# 下载 x-ui 二进制文件
echo "下载 x-ui-linux-amd64.tar.gz..."
wget -O x-ui-linux-amd64.tar.gz https://github.com/MHSanaei/3x-ui/releases/download/v2.3.9/x-ui-linux-amd64.tar.gz

# 解压
tar -xzf x-ui-linux-amd64.tar.gz
chmod +x x-ui

# 下载官方管理脚本
echo "下载管理脚本 x-ui.sh..."
wget -O /usr/bin/x-ui https://raw.githubusercontent.com/MHSanaei/3x-ui/main/x-ui.sh
chmod +x /usr/bin/x-ui

# 创建 systemd 服务
echo "创建 systemd 服务..."
cat >/etc/systemd/system/x-ui.service <<EOF
[Unit]
Description=X-UI Service
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/x-ui/x-ui
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable x-ui

# 安装完成提示
echo "安装完成！你可以运行 'x-ui' 进入管理菜单"
echo "第一次运行将提示你设置面板端口、用户名、密码"

# 启动菜单安装向导
x-ui
