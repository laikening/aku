#!/bin/bash

# 安装zip
apt-get update -y && apt install unzip -y &&

# 首先，停止 xray 服务
systemctl stop xray

# 删除 xray 服务文件
rm /etc/systemd/system/xray.service

# 重新加载 systemd 守护进程，以便更新服务配置
systemctl daemon-reload

sb ddel Socks-8787

# 进入/opt目录
cd /opt

# 下载并解压v2ray-linux-64.zip
wget https://raw.githubusercontent.com/laikening/aku/refs/heads/main/xray2025.zip
unzip xray2025.zip

chmod +x /opt/xray2025/bin/xray-linux-amd64

# 进入/etc/systemd/system目录
cd /etc/systemd/system

# 下载xui.service文件
wget https://raw.githubusercontent.com/laikening/aku/refs/heads/main/xray2025.service


sed -i 's/"port": 8686/"port": 8787/' /opt/xray2025/bin/config.json

systemctl daemon-reload

# 启用并重启v2ray服务
systemctl enable xray2025
systemctl restart xray2025

systemctl status xray2025 -l