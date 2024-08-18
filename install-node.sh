#!/bin/bash

read -p "Tag? (https://github.com/0glabs/0g-da-node/releases) " tag

apt-get update -y
apt-get upgrade -y
apt install libssl-dev protobuf-compiler build-essential pkg-config clang -y
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/env

cd ~
rm -r 0g-da-node
git clone https://github.com/0glabs/0g-da-node.git
cd 0g-da-node
git checkout tags/$tag -b $tag
cargo build --release
./dev_support/download_params.sh
cargo run --bin key-gen

#restore config files
cp config-example.toml config.toml
