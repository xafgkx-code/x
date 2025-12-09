#!/bin/bash

# ============================
# X-UI v2.3.9 一键安装优化版（固定参数，无需交互）
# ============================

set -e

# ----------- 固定参数 -----------
XUI_PORT=3030
XUI_USER="AFGK"
XUI_PASS="AFGK"
ENABLE_BBR="y"

# ----------- 停止旧进程 -----------
if systemctl is-active --quiet x-ui; then
    echo "检测到 X-UI systemd 服务正在运行，正在停止..."
    systemctl stop x-ui
elif pgrep x-ui > /dev/null; then
    echo "检测到 X-UI 进程，正在强制停止..."
    pkill -9 x-ui
fi

# ----------- 清理旧版 -----------
if [ -d /usr/local/x-ui ]; then
    echo "正在删除旧版 X-UI 文件..."
    rm -rf /usr/local/x-ui
fi

if [ -f /etc/systemd/system/x-ui.service ]; then
    echo "正在删除旧 systemd 服务..."
    rm -f /etc/systemd/system/x-ui.service
    systemctl daemon-reload
fi

# ----------- 安装 X-UI -----------
echo "开始安装 X-UI 2.3.9..."
mkdir -p /usr/local/x-ui
cd /usr/local/x-ui

echo "下载 X-UI..."
if ! curl -fsSL https://github.com/MHSanaei/3x-ui/releases/download/v2.3.9/x-ui-linux-amd64.tar.gz -o x-ui-linux-amd64.tar.gz; then
    echo "下载失败，请检查网络或 GitHub 链接！"
    exit 1
fi

echo "解压 X-UI..."
tar -xzf x-ui-linux-amd64.tar.gz

# ----------- 修复可执行文件路径 -----------
if [ -f "x-ui-linux-amd64/x-ui" ]; then
    chmod +x x-ui-linux-amd64/x-ui
    mv x-ui-linux-amd64/x-ui /usr/local/x-ui/x-ui
elif [ -f "x-ui" ]; then
    chmod +x x-ui
else
    echo "解压后找不到可执行文件 x-ui！"
    exit 1
fi

# ----------- 创建 systemd 服务 -----------
cat >/etc/systemd/system/x-ui.service <<EOF
[Unit]
Description=X-UI Service
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/x-ui/x-ui -port $XUI_PORT
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable x-ui
systemctl start x-ui

# 等待面板启动
sleep 3

# ----------- 设置用户名密码 -----------
/usr/local/x-ui/x-ui setting -username $XUI_USER -password $XUI_PASS || true

# ----------- 开启 BBR -----------
if [[ "$ENABLE_BBR" =~ ^[Yy]$ ]]; then
    echo "正在开启 BBR..."
    grep -q "tcp_congestion_control=bbr" /etc/sysctl.conf || echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
    grep -q "default_qdisc=fq" /etc/sysctl.conf || echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
    sysctl -p
    echo "BBR 已启用"
fi

# ----------- 显示访问信息 -----------
IP=$(curl -s ifconfig.me || hostname -I | awk '{print $1}')
echo "================================================="
echo "X-UI 安装完成！"
echo "访问地址: http://$IP:$XUI_PORT"
echo "用户名: $XUI_USER  密码: $XUI_PASS"
echo "================================================="
