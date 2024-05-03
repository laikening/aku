sed -i 's/aes-128-gcm/aes-256-gcm/g' /opt/v2ss/bin/config.json&&
systemctl daemon-reload&&
systemctl enable v2ray&&
systemctl restart v2ray&&
systemctl status v2ray -l
