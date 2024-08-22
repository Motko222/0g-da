#!/bin/bash

source ~/scripts/0g-chain/cfg
source ~/.bash_profile

#generic
grp=da
network=testnet
chain=newton

#get folder size
folder_size=$(du -hs -L ~/0g-da-node | awk '{print $1}')

#get RPC addresses
node_rpc=$(cat ~/0g-da-node/config.toml | grep '^grpc_listen_address =' | tail -1 | awk '{print $3}' | sed 's/"//g')
disperser_rpc=localhost:51001

#get da node info
cd ~/0g-da-node/target/release
node_version=$(./server --version | awk '{print $2}')
cd ~
node_status=$(./grpcurl --plaintext --import-path ~/ --proto ~/signer.proto $node_rpc signer.Signer/GetStatus | jq -r .statusCode)
disperser_status=$(./grpcurl --plaintext $disperser_rpc grpc.health.v1.Health/Check | jq -r .status )

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
   { "key":"disperser_status","value":"$disperser_status" }
  ]
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
    report,machine=$MACHINE,id=$ID,grp=$grp,owner=$OWNER status=\"$status\",message=\"$message\",node_version=\"$node_version\",node_rpc=\"$node_rpc\",chain=\"$chain\",node_status=\"$node_status\",disperser_status=\"$disperser_status\" $(date +%s%N) 
    "
fi
