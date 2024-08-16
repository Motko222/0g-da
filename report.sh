#!/bin/bash

source ~/scripts/0g-chain/cfg
source ~/.bash_profile

#generic
grp=da
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
  "measurement":"report",
  "tags": [   
   { "key":"id","value":"$ID" },
   { "key":"machine","value":"$MACHINE" },
   { "key":"grp","value":"$grp" },
   { "key":"owner","value":"$OWNER" }
  ],
  "fields": [
   { "key":"folder_size","value":"$folder_size" },
   { "key":"node_rpc","value":"$node_rpc" },
   { "key":"node_version","value":"$node_version" },
   { "key":"node_status","value":"$node_status" },
  ],
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
    report,machine=$MACHINE,id=$id,grp=$group,owner=$OWNER status=\"$status\",message=\"$message\",node_version=\"$node_version\",node_rpc=\"$node_rpc\",chain=\"$chain\",node_status=\"$node_status\" $(date +%s%N) 
    "
fi
