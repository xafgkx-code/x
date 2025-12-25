#!/bin/bash
set -e

# ============================
# 3X-UI v2.3.9 一键安装脚本（无交互 · 稳定版）
# ============================

# -------- 固定参数 --------
XUI_PORT=3030
XUI_USER="AFGK"
XUI_PASS="AFGK"
ENABLE_BBR="y"
INSTALL_DIR="/usr/local/x-ui"

# -------- 权限检测 --------
if [ "$(id -u)" != "0" ]; then
  echo "请使用 root 用户运行"
  exit 1
fi

# -------- 停止旧服务 --------
systemctl stop x-ui 2>/dev/null || true
pkill -9 x-ui 2>/dev/null || true

# -------- 清理旧文件 --------
rm -rf ${INSTALL_DIR}
rm -f /etc/systemd/system/x-ui.service
systemctl daemon-reload

# -------- 下载 3x-ui --------
echo "下载 3x-ui v2.3.9..."
mkdir -p ${INSTALL_DIR}
cd ${INSTALL_DIR}

curl -fsSL \
https://github.com/MHSanaei/3x-ui/releases/download/v2.3.9/x-ui-linux-amd64.tar.gz \
-o x-ui.tar.gz

tar -xzf x-ui.tar.gz

# -------- 修正可执行文件 --------
if [ -f "x-ui/x-ui" ]; then
  chmod +x x-ui/x-ui
  mv x-ui/x-ui ${INSTALL_DIR}/x-ui
else
  echo "未找到 x-ui 可执行文件"
  exit 1
fi

# -------- 创建 systemd --------
cat >/etc/systemd/system/x-ui.service <<EOF
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
systemctl enable x-ui
systemctl start x-ui

# -------- 等待启动 --------
sleep 5

# -------- 设置账号密码端口 --------
${INSTALL_DIR}/x-ui setting \
  -username ${XUI_USER} \
  -password ${XUI_PASS} \
  -port ${XUI_PORT} || true

systemctl restart x-ui

# -------- 安全开启 BBR --------
if [[ "$ENABLE_BBR" =~ ^[Yy]$ ]]; then
  if sysctl net.ipv4.tcp_available_congestion_control | grep -q bbr; then
    echo "启用 BBR..."
    echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
    echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
    sysctl -p
  else
    echo "当前内核不支持 BBR，已跳过"
  fi
fi

# -------- 输出信息 --------
IP=$(curl -s ifconfig.me ||
