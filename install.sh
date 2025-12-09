#!/bin/bash

# ============================
# X-UI v2.3.9 一键安装 / 卸载 / 升级 脚本
# 作者：AFGK
# ============================

set -e

# 配置
XUI_DIR="/usr/local/x-ui"
XUI_USER_SYS="xuiuser"
XUI_PORT=3030
XUI_USER="AFGK"
XUI_PASS="AFGK"
SERVICE_NAME="x-ui"
DOWNLOAD_URL="https://github.com/MHSanaei/3x-ui/releases/download/v2.3.9/x-ui-linux-amd64.tar.gz"

# 功能选择
echo "请选择操作："
echo "1) 安装 X-UI v2.3.9"
echo "2) 卸载 X-UI"
echo "3) 升级 X-UI"
read -rp "请输入选项 (1/2/3): " CHOICE

install_xui() {
    echo "========================================"
    echo "     安装 X-UI v2.3.9"
    echo "========================================"

    # 安装依赖
    apt update
    apt install -y wget tar curl ufw

    # 创建系统用户
    if ! id -u $XUI_USER_SYS >/dev/null 2>&1; then
        useradd -r -s /usr/sbin/nologin $XUI_USER_SYS
    fi

    # 创建目录
    mkdir -p $XUI_DIR
    chown -R $XUI_USER_SYS:$XUI_USER_SYS $XUI_DIR
    cd $XUI_DIR

    # 下载并解压
    echo "下载 X-UI..."
    wget -O x-ui-linux-amd64.tar.gz $DOWNLOAD_URL
    tar -xzf x-ui-linux-amd64.tar.gz
    chmod +x x-ui
    chown $XUI_USER_SYS:$XUI_USER_SYS x-ui

    # 配置面板端口和账号
    cat > $XUI_DIR/config.yml <<EOF
panel:
  listen: 0.0.0.0:$XUI_PORT
  username: $XUI_USER
  password: $XUI_PASS
EOF
    chown $XUI_USER_SYS:$XUI_USER_SYS config.yml

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
User=$XUI_USER_SYS

[Install]
WantedBy=multi-user.target
EOF

    # 启动服务
    systemctl daemon-reload
    systemctl enable $SERVICE_NAME
    systemctl start $SERVICE_NAME

    # 开放防火墙端口
    if command -v ufw >/dev/null 2>&1; then
        ufw allow $XUI_PORT/tcp
    fi

    echo "========================================"
    echo "安装完成！"
    echo "访问面板：http://$(curl -s ifconfig.me):$XUI_PORT"
    echo "用户名：$XUI_USER  密码：$XUI_PASS"
    echo "启动命令：systemctl start $SERVICE_NAME"
    echo "停止命令：systemctl stop $SERVICE_NAME"
    echo "重启命令：systemctl restart $SERVICE_NAME"
    echo "卸载命令：选择脚本中的卸载选项"
    echo "========================================"
}

uninstall_xui() {
    echo "========================================"
    echo "     卸载 X-UI"
    echo "========================================"

    systemctl stop $SERVICE_NAME || true
    systemctl disable $SERVICE_NAME || true
    rm -f /etc/systemd/system/$SERVICE_NAME.service
    systemctl daemon-reload

    rm -rf $XUI_DIR
    if id -u $XUI_USER_SYS >/dev/null 2>&1; then
        userdel $XUI_USER_SYS || true
    fi

    echo "X-UI 已成功卸载"
    echo "========================================"
}

upgrade_xui() {
    echo "========================================"
    echo "     升级 X-UI"
    echo "========================================"
    systemctl stop $SERVICE_NAME || true
    install_xui
    echo "X-UI 升级完成！"
    echo "========================================"
}

case $CHOICE in
    1) install_xui ;;
    2) uninstall_xui ;;
    3) upgrade_xui ;;
    *) echo "无效选项"; exit 1 ;;
esac
