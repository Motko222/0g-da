#!/bin/bash

sudo systemctl restart 0g-da-retriever
sudo journalctl 0g-da-retriever -f --no-hostname -o cat
