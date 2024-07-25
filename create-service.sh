 #!/bin/bash

sudo tee /etc/systemd/system/0g-da-node.service > /dev/null <<EOF
[Unit]
Description=0g da node
After=network.target
StartLimitIntervalSec=0
[Service]
User=root
WorkingDirectory=/root/0g-da-node
ExecStart=/root/0g-da-node/target/release/server --config /root/0g-da-node/config.toml
Restart=always
RestartSec=30
[Install]
WantedBy=multi-user.target
EOF

sudo tee /etc/systemd/system/0g-da-client.service > /dev/null <<EOF
[Unit]
Description=0g da client
After=network.target
StartLimitIntervalSec=0
[Service]
User=root
WorkingDirectory=/root/0g-da-xxx
ExecStart=echo
Restart=always
RestartSec=30
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable 0g-da-node
sudo systemctl enable 0g-da-client

