#!/bin/bash

read -p "Sure? " yn
case $yn in
 y|Y|yes|Yes|YES) ;;
 *) exit ;;
esac

#backup config files
[ -d ~/backup ] || mkdir ~/backup
[ -d ~/backup/0g-da-node ] || mkdir ~/backup/0g-da-node
cp ~/0g-da-node/config.toml ~/backup/0g-da-node/config.toml

apt install libssl-dev
apt install protobuf-compiler

cd ~
rm -r 0g-da-node
git clone https://github.com/0glabs/0g-da-node.git
cd 0g-da-node
cargo build --release
./dev_support/download_params.sh
cargo run --bin key-gen

#restore config files
cp ~/backup/0g-da-node/config.toml ~/0g-da-node/config.toml
