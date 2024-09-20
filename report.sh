#!/bin/bash

source ~/scripts/0g-chain/cfg
source ~/.bash_profile

#generic
grp=da
network=testnet
chain=newton
owner=$OWNER

#get folder size
folder_size=$(du -hs -L ~/0g-da-node | awk '{print $1}')

#get RPC addresses
node_rpc=$(cat ~/0g-da-node/config.toml | grep '^grpc_listen_address =' | tail -1 | awk '{print $3}' | sed 's/"//g')
chain_rpc=$(cat ~/0g-da-node/config.toml | grep '^eth_rpc_endpoint =' | tail -1 | awk '{print $3}' | sed 's/"//g')
disperser_rpc=localhost:51001

#get da node info
cd ~/0g-da-node/target/release
node_version=$(./server --version | awk '{print $2}')
cd ~
node_status=$(./grpcurl --plaintext --import-path ~/ --proto ~/signer.proto $node_rpc signer.Signer/GetStatus | jq -r .statusCode)
disperser_status=$(./grpcurl --plaintext $disperser_rpc grpc.health.v1.Health/Check | jq -r .status )
retriever_status=$(systemctl status 0g-da-retriever --no-pager | grep Active | awk '{print $2}')

cat << EOF
{
  "updated":"$(date --utc +%FT%TZ)",
  "measurement":"report",
  "tags": [   
   { "id","$ID" },
   { "machine","$MACHINE" },
   { "grp","$grp" },
   { "owner","$OWNER" }
  ],
  "fields": [
   { "folder_size","$folder_size" },
   { "node_rpc","$node_rpc" },
   { "chain_rpc","$chain_rpc" },
   { "node_version","$node_version" },
   { "node_status","$node_status" },
   { "disperser_status","$disperser_status" },
   { "retriever_status","$retriever_status" }
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
    report,machine=$MACHINE,id=$ID,grp=$grp,owner=$OWNER status=\"$status\",message=\"$message\",node_version=\"$node_version\",node_rpc=\"$node_rpc\",chain=\"$chain\",node_status=\"$node_status\",disperser_status=\"$disperser_status\",retriever_status=\"$retriever_status\" $(date +%s%N) 
    "
fi
