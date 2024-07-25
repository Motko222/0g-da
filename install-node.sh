#!/bin/bash

cd ~
git clone https://github.com/0glabs/0g-da-node.git
cd 0g-da-node
cargo build --release
./dev_support/download_params.sh

