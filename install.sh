#!/bin/bash
set -e

# ============================
# 3X-UI v2.3.9 一键安装脚本（修正版）
# ============================

# -------- 固定参数 --------
XUI_VERSION="v2.3.9"
XUI_PORT=3030
XUI_USER="AFGK"
XUI_PASS="AFGK"
ENABLE_BBR="y"
INSTALL_DIR="/usr/local/x-ui"
SERVICE_NAME="x-ui"
DOWNLOAD_URL="https://github.com/MHSanaei/3x-ui/releases/download/v2.3.9/x-ui-linux-amd64.tar.gz"

# -------- 权限检查 --------
if [ "$(id -u)" != "0" ]; then
    echo "请使用 root 用户运行"
    exit 1
fi

# -------- 停止旧服务 --------
systemctl stop $SERVICE_NAME 2>/dev/null || true
pkill -9 x-ui 2>/dev/null || true

# -------- 清理旧文件 --------
rm -rf ${INSTALL_DIR}
rm -f /etc/systemd/system/${SERVICE_NAME}.service
systemctl daemon-reload

# -------- 安装依赖 --------
apt update -y
apt install wget tar curl socat -y

# -------- 下载并解压 --------
echo "下载 3x-ui $XUI_VERSION..."
mkdir -p ${INSTALL_DIR}
cd ${INSTALL_DIR}

curl -fsSL $DOWNLOAD_URL -o x-ui.tar.gz
tar -xzf x-ui.tar.gz

# -------- 修正可执行文件路径 --------
if [ -f "x-ui/x-ui" ]; then
    chmod +x x-ui/x-ui
    mv x-ui/x-ui ./x-ui       # 移动到根目录
    rm -rf x-ui               # 删除解压目录
else
    echo "未找到 x-ui 可执行文件"
    exit 1
fi

# -------- 创建 systemd 服务 --------
cat >/etc/systemd/system/${SERVICE_NAME}.service <<EOF
[Unit]
Description=3X-UI Service
After=network.target

[Service]
Type=simple
ExecStart=${INSTALL_DIR}/x-ui run
Restart=always
LimitNOFILE=51200

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable $SERVICE_NAME
systemctl start $SERVICE_NAME

# -------- 等待启动 --------
sleep 5

# -------- 设置账号密码端口 --------
${INSTALL_DIR}/x-ui setting -username $XUI_USER -password $XUI_PASS -port $XUI_PORT || true
systemctl restart $SERVICE_NAME

# -------- 安全开启 BBR --------
if [[ "$ENABLE_BBR" =~ ^[Yy]$ ]]; then
    if sysctl net.ipv4.tcp_available_congestion_control | grep -q bbr; then
        echo "启用 BBR..."
        grep -qxF "net.core.default_qdisc=fq" /etc/sysctl.conf || echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
        grep -qxF "net.ipv4.tcp_congestion_control=bbr" /etc/sysctl.conf || echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
        sysctl -p
    else
        echo "当前内核不支持 BBR，已跳过"
    fi
fi

# -------- 输出访问信息 --------
IP=$(curl -s ifconfig.me || hostname -I | awk '{print $1}')
echo "======================================="
echo "3X-UI 安装完成"
echo "访问地址: http://${IP}:${XUI_PORT}"
echo "用户名: $XUI_USER"
echo "密码: $XUI_PASS"
echo "======================================="
