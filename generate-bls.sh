#!/bin/bash

cd ~/0g-da-node
read -p "Count? " count
for (( i=1; i<=$count; i++ ))
do
 cargo run --bin key-gen 2>/dev/null
done
