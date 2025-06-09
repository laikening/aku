#!/bin/bash

sed -i 's/"port": 8787/"port": 8686/' /opt/xray2025/bin/config.json

systemctl daemon-reload

# 启用并重启v2ray服务
systemctl enable xray2025
systemctl restart xray2025

systemctl status xray2025 -l
