#!/bin/bash

systemctl daemon-reload

# 启用并重启v2ray服务
systemctl enable xray2025
systemctl restart xray2025

systemctl status xray2025 -l
