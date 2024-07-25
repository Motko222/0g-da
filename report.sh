#!/bin/bash

source ~/scripts/0g-chain/cfg
source ~/.bash_profile

#generic
group=na
network=testnet
chain=newton
id=$ID

#get folder size
folder_size=$(du -hs -L ~/0g-da-node | awk '{print $1}')

#get RPC addresses
node_rpc=$(cat ~/0g-da-node/config.toml | grep '^grpc_listen_address =' | tail -1 | awk '{print $3}' | sed 's/"//g')

#get da node info
cd ~/0g-da-node/target/release
node_version=$(./server --version | awk '{print $2}')
cd ~
json=$(./grpcurl --plaintext --import-path ~/ --proto ~/signer.proto $node_rpc signer.Signer/GetStatus)
node_status=$(echo $json | jq -r .statusCode)

cat << EOF
{
  "updated":"$(date --utc +%FT%TZ)",
  "id":"$ID",
  "machine":"$MACHINE",
  "folder_size":"$folder_size",
  "node_rpc":"$node_rpc",
  "node_version":"$node_version",
  "node_status":"$node_height",
}
EOF

# send data to influxdb
if [ ! -z $INFLUX_HOST ]
then
 curl --request POST \
 "$INFLUX_HOST/api/v2/write?org=$INFLUX_ORG&bucket=$INFLUX_BUCKET&precision=ns" \
  --header "Authorization: Token $INFLUX_TOKEN" \
  --header "Content-Type: text/plain; charset=utf-8" \
  --header "Accept: application/json" \
  --data-binary "
    report,machine=$MACHINE,id=$id,grp=$group status=\"$status\",message=\"$message\",version=\"$version\",url=\"$url\",chain=\"$chain\",node_status=\"$node_status\" $(date +%s%N) 
    "
fi
