#!/bin/bash

read -p "Tag ? (https://github.com/0glabs/0g-da-client/releases) " tag

cd ~
git clone -b $tag https://github.com/0glabs/0g-da-client.git
cd 0g-da-client
make build
docker build -t 0gclient -f ~/0g-da-client/Dockerfile .

cd run
chmod +x ./start.sh
chmod +x ./run.sh


