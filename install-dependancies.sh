#~/bin/bash

apt-get update -y
apt-get upgrade -y
apt install libssl-dev protobuf-compiler build-essential pkg-config clang -y
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/env
