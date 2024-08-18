#!/bin/bash

path=$(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd)

read -p "Tag? (https://github.com/0glabs/0g-da-node/releases) " tag

#backup config files
[ -d ~/backup ] || mkdir ~/backup
[ -d ~/backup/0g-da-node ] || mkdir ~/backup/0g-da-node
cp ~/0g-da-node/config.toml ~/backup/0g-da-node/config.toml

#stop node
cd ~
./stop-node.sh

#wipe and build
rm -r 0g-da-node
git clone https://github.com/0glabs/0g-da-node.git
cd 0g-da-node
git checkout tags/$tag -b $tag
cargo build --release
./dev_support/download_params.sh

#restore config files
cp ~/backup/0g-da-node/config.toml ~/0g-da-node/config.toml

#start-node
cd $path
./start-node.sh
