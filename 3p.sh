#!/bin/bash

# 3proxy 多IP站群自动安装脚本
# 专为游戏代理优化，支持精确IP绑定

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 配置参数
SOCKS5_PORT=8989  # 所有IP使用相同端口

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  3proxy 多IP站群自动安装脚本${NC}"
echo -e "${GREEN}  专为游戏代理优化${NC}"
echo -e "${GREEN}========================================${NC}"

# 检查 root 权限
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}请使用 root 权限运行此脚本${NC}"
    exit 1
fi

# 自动检测服务器地理位置并设置DNS
echo -e "${YELLOW}正在检测服务器地理位置...${NC}"
SERVER_COUNTRY=$(curl -s --max-time 5 ipinfo.io/country || echo "UNKNOWN")

if [ "$SERVER_COUNTRY" = "HK" ]; then
    DNS_SERVER="8.8.8.8"
    echo -e "${GREEN}检测到香港服务器，使用 Google DNS: ${DNS_SERVER}${NC}"
elif [ "$SERVER_COUNTRY" = "KR" ]; then
    DNS_SERVER="210.220.163.82"
    echo -e "${GREEN}检测到韩国服务器，使用 SK DNS: ${DNS_SERVER}${NC}"
else
    DNS_SERVER="8.8.8.8"
    echo -e "${YELLOW}未识别地区 (${SERVER_COUNTRY})，默认使用 Google DNS: ${DNS_SERVER}${NC}"
fi

# 检测系统架构
ARCH=$(uname -m)
echo -e "${YELLOW}检测到系统架构: $ARCH${NC}"

# 获取所有公网IP
echo -e "${YELLOW}正在检测服务器IP地址...${NC}"
IPS=($(ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v '^127\.' | grep -v '^10\.' | grep -v '^172\.(1[6-9]|2[0-9]|3[0-1])\.' | grep -v '^192\.168\.'))

if [ ${#IPS[@]} -eq 0 ]; then
    echo -e "${RED}未检测到公网IP地址，尝试获取所有IP...${NC}"
    IPS=($(ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v '^127\.'))
fi

if [ ${#IPS[@]} -eq 0 ]; then
    echo -e "${RED}无法检测到任何IP地址${NC}"
    exit 1
fi

# 根据IP数量自动设置账号密码
if [ ${#IPS[@]} -eq 1 ]; then
    SOCKS5_USER="888"
    SOCKS5_PASS="888"
    echo -e "${GREEN}检测到单IP服务器，账号密码设置为: 888/888${NC}"
else
    SOCKS5_USER="mimi"
    SOCKS5_PASS="mimi"
    echo -e "${GREEN}检测到多IP服务器 (${#IPS[@]} 个IP)，账号密码设置为: mimi/mimi${NC}"
fi

echo -e "${GREEN}检测到 ${#IPS[@]} 个IP地址:${NC}"
for i in "${!IPS[@]}"; do
    echo -e "  [$((i+1))] ${IPS[$i]}"
done

# 安装依赖
echo -e "${YELLOW}正在安装依赖包...${NC}"
if command -v apt-get &> /dev/null; then
    apt-get update
    apt-get install -y wget
elif command -v yum &> /dev/null; then
    yum install -y wget
else
    echo -e "${RED}不支持的包管理器${NC}"
    exit 1
fi

# 检测系统架构并下载对应的预编译版本
case $ARCH in
    x86_64)
        DOWNLOAD_URL="https://github.com/3proxy/3proxy/releases/download/0.9.4/3proxy-0.9.4.x86_64.deb"
        PACKAGE_TYPE="deb"
        ;;
    aarch64)
        DOWNLOAD_URL="https://github.com/3proxy/3proxy/releases/download/0.9.4/3proxy-0.9.4.arm64.deb"
        PACKAGE_TYPE="deb"
        ;;
    *)
        echo -e "${YELLOW}未找到预编译版本，尝试从源码编译...${NC}"
        apt-get install -y gcc make
        cd /tmp
        wget -O 3proxy.tar.gz https://github.com/3proxy/3proxy/archive/refs/tags/0.9.4.tar.gz
        tar -xzf 3proxy.tar.gz
        cd 3proxy-0.9.4
        # 添加编译参数忽略类型警告
        sed -i 's/CFLAGS =/CFLAGS = -Wno-error=incompatible-pointer-types/' Makefile.Linux
        make -f Makefile.Linux
        mkdir -p /etc/3proxy /var/log/3proxy
        cp bin/3proxy /usr/local/bin/
        chmod +x /usr/local/bin/3proxy
        cd /tmp
        rm -rf 3proxy.tar.gz 3proxy-0.9.4
        ;;
esac

# 如果是预编译包，直接安装
if [ "$PACKAGE_TYPE" = "deb" ]; then
    echo -e "${YELLOW}正在下载 3proxy 预编译版本...${NC}"
    cd /tmp
    wget -O 3proxy.deb "$DOWNLOAD_URL" || {
        echo -e "${RED}下载失败，尝试从源码编译...${NC}"
        apt-get install -y gcc make
        wget -O 3proxy.tar.gz https://github.com/3proxy/3proxy/archive/refs/tags/0.9.4.tar.gz
        tar -xzf 3proxy.tar.gz
        cd 3proxy-0.9.4
        sed -i 's/CFLAGS =/CFLAGS = -Wno-error=incompatible-pointer-types/' Makefile.Linux
        make -f Makefile.Linux
        mkdir -p /etc/3proxy /var/log/3proxy
        cp bin/3proxy /usr/local/bin/
        chmod +x /usr/local/bin/3proxy
        cd /tmp
        rm -rf 3proxy.tar.gz 3proxy-0.9.4
    }

    if [ -f /tmp/3proxy.deb ]; then
        echo -e "${YELLOW}正在安装 3proxy...${NC}"
        dpkg -i 3proxy.deb || true
        rm -f 3proxy.deb
    fi
fi

# 优化系统内核参数
echo -e "${YELLOW}正在优化系统内核参数...${NC}"
cat >> /etc/sysctl.conf <<'SYSCTL_EOF'

# 3proxy 网络性能优化
net.core.somaxconn = 65535
net.ipv4.tcp_max_syn_backlog = 8192
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_fin_timeout = 30
net.ipv4.ip_local_port_range = 1024 65535
net.core.netdev_max_backlog = 16384
net.ipv4.tcp_keepalive_time = 600
net.ipv4.tcp_keepalive_intvl = 30
net.ipv4.tcp_keepalive_probes = 3
SYSCTL_EOF

sysctl -p > /dev/null 2>&1
echo -e "${GREEN}系统内核参数优化完成${NC}"

# 确保目录存在
mkdir -p /etc/3proxy
mkdir -p /var/log/3proxy

# 确保 3proxy 可执行
if [ ! -f /usr/local/bin/3proxy ] && [ -f /usr/bin/3proxy ]; then
    cp /usr/bin/3proxy /usr/local/bin/3proxy
fi
chmod +x /usr/local/bin/3proxy 2>/dev/null || true

# 生成配置文件
echo -e "${YELLOW}正在生成配置文件...${NC}"

cat > /etc/3proxy/3proxy.cfg <<EOF
# 3proxy 配置文件 - 多IP站群游戏代理
# 日志配置
log /var/log/3proxy/3proxy.log D
logformat "- +_L%t.%. %N.%p %E %U %C:%c %R:%r %O %I %h %T"
rotate 30

# DNS 配置
nserver ${DNS_SERVER}
nscache 65536

# 认证配置
auth strong
users ${SOCKS5_USER}:CL:${SOCKS5_PASS}

# 性能优化（游戏代理优化）
maxconn 65535
timeouts 60 120 60 120 300 3600 30 120

# 允许所有目标
allow ${SOCKS5_USER}

EOF

# 为每个IP配置 SOCKS5 代理（所有IP使用相同端口）
for i in "${!IPS[@]}"; do
    IP="${IPS[$i]}"

    cat >> /etc/3proxy/3proxy.cfg <<EOF

# IP ${IP} - 端口 ${SOCKS5_PORT}
socks -i${IP} -p${SOCKS5_PORT} -e${IP}
EOF
done

echo -e "${GREEN}配置文件已生成: /etc/3proxy/3proxy.cfg${NC}"

# 创建 systemd 服务
echo -e "${YELLOW}正在创建 systemd 服务...${NC}"
cat > /etc/systemd/system/3proxy.service <<EOF
[Unit]
Description=3proxy Proxy Server
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/3proxy /etc/3proxy/3proxy.cfg
ExecReload=/bin/kill -HUP \$MAINPID
Restart=on-failure
RestartSec=5s
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

# 启动服务
systemctl daemon-reload
systemctl enable 3proxy
systemctl start 3proxy

# 配置防火墙
echo -e "${YELLOW}正在配置防火墙...${NC}"
if command -v ufw &> /dev/null; then
    ufw allow ${SOCKS5_PORT}/tcp
elif command -v firewall-cmd &> /dev/null; then
    firewall-cmd --permanent --add-port=${SOCKS5_PORT}/tcp
fi

if command -v ufw &> /dev/null; then
    echo -e "${GREEN}UFW 防火墙规则已添加${NC}"
elif command -v firewall-cmd &> /dev/null; then
    firewall-cmd --reload
    echo -e "${GREEN}firewalld 防火墙规则已添加${NC}"
else
    echo -e "${YELLOW}未检测到防火墙，请手动开放端口${NC}"
fi

# 检查服务状态
sleep 2
if systemctl is-active --quiet 3proxy; then
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}  3proxy 安装成功！${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}已配置 ${#IPS[@]} 个IP的 SOCKS5 代理${NC}"
    echo -e "${YELLOW}DNS 服务器: ${DNS_SERVER}${NC}"
    echo -e ""

    for i in "${!IPS[@]}"; do
        IP="${IPS[$i]}"

        echo -e "${YELLOW}[IP $((i+1))] ${IP}${NC}"
        echo -e "  SOCKS5 地址: ${IP}:${SOCKS5_PORT}"
        echo -e "  用户名: ${SOCKS5_USER}"
        echo -e "  密码: ${SOCKS5_PASS}"
        echo -e "  ${GREEN}✓ 入站IP和出站IP已精确绑定${NC}"
        echo -e ""
    done

    echo -e "${GREEN}常用命令:${NC}"
    echo -e "  启动服务: systemctl start 3proxy"
    echo -e "  停止服务: systemctl stop 3proxy"
    echo -e "  重启服务: systemctl restart 3proxy"
    echo -e "  查看状态: systemctl status 3proxy"
    echo -e "  查看日志: tail -f /var/log/3proxy/3proxy.log"
    echo -e "  查看配置: cat /etc/3proxy/3proxy.cfg"
    echo -e ""
    echo -e "${YELLOW}性能特点:${NC}"
    echo -e "  - 低延迟，适合游戏代理"
    echo -e "  - 资源占用极低"
    echo -e "  - 原生支持多IP绑定"
    echo -e "  - 稳定性极高"
    echo -e "${GREEN}========================================${NC}"
else
    echo -e "${RED}3proxy 启动失败，请检查日志: journalctl -u 3proxy -xe${NC}"
    exit 1
fi
