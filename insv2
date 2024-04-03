#!/bin/bash

# 进入/opt目录
cd /opt

# 下载并解压v2ray-linux-64.zip
wget https://xgxray.oss-cn-hongkong.aliyuncs.com/v2ray-linux-64.zip
unzip v2ray-linux-64.zip
chmod +x v2ray

# 下载并解压v2ss.zip
wget https://xgxray.oss-cn-hongkong.aliyuncs.com/v2ss.zip
unzip v2ss.zip

# 进入v2ss/bin目录
cd /opt/v2ss/bin

# 生成私钥和相同的密码
./gen -private -samepasswd

# 修改端口为10001列序
wget https://xgxray.oss-cn-hongkong.aliyuncs.com/YY/10001.sh
chmod +x 10001.sh
./10001.sh

# 修改config.txt里的密码为mimi
sed -i 's/passwd = .*/passwd = mimi/' config.txt
sed -i 's/user = .*/user = mimi/' config.txt

# txt生成json
./gen -ii config.txt

# 进入/etc/systemd/system目录
cd /etc/systemd/system

# 下载v2ray.service文件
wget https://xgxray.oss-cn-hongkong.aliyuncs.com/v2ray.service

# 重新加载systemd管理器配置
systemctl daemon-reload

# 启用并重启v2ray服务
systemctl enable v2ray
systemctl restart v2ray

# 关闭debian10 防火墙
ufw disable

# 查看v2状态
systemctl status v2ray -l
