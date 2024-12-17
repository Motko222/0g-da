#!/bin/bash

read -p "Tag? (https://github.com/0glabs/0g-da-node/releases) " tag

source $HOME/.cargo/env

#backup config files
[ -d ~/backup ] || mkdir ~/backup
[ -d ~/backup/0g-da-node ] || mkdir ~/backup/0g-da-node
cp ~/0g-da-node/config.toml ~/backup/0g-da-node/config.toml

#deploy
cd ~
rm -r 0g-da-node
git clone https://github.com/0glabs/0g-da-node.git
cd 0g-da-node
git checkout tags/$tag -b $tag
cargo build --release
./dev_support/download_params.sh
cargo run --bin key-gen

#restore config files
cp ~/backup/0g-da-node/config.toml ~/0g-da-node/config.toml

#save version
echo $tag >/root/logs/da-node-version
