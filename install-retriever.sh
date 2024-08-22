#!/bin/bash

read -p "Tag? (https://github.com/0glabs/0g-da-retriever/releases) " tag

source $HOME/.cargo/env

#backup config files
[ -d ~/backup ] || mkdir ~/backup
[ -d ~/backup/0g-da-retriever ] || mkdir ~/backup/0g-da-retriever
cp ~/0g-da-retriever/run/config.toml ~/backup/0g-da-retriever/config.toml

#deploy
cd ~
rm -r 0g-da-retriever
git clone https://github.com/0glabs/0g-da-node.git
cd 0g-da-retriever
git checkout tags/$tag -b $tag
cargo build --release

#restore config files
cp ~/backup/0g-da-retriever/config.toml ~/0g-da-retriever/run/config.toml
