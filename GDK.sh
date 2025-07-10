#!/bin/bash

cd  /opt/xray2025/bin/
find . -type f -name '*.json' -exec sed -i 's/888/gw888/g' {} +
systemctl daemon-reload
systemctl enable xray2025
systemctl restart xray2025
