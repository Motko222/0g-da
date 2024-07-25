#!/bin/bash

sudo systemctl restart 0g-da-node
sudo journalctl 0g-da-node -f --no-hostname -o cat
