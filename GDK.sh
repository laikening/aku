cd  /opt/xray2025/bin/
find . -type f -name '*.json' -exec sed -i 's/8787/8989/g' {} +
systemctl daemon-reload
systemctl enable xray2025
systemctl restart xray2025
