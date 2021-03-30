#!/usr/bin/env nix-shell
#!nix-shell -I nixpkgs=https://github.com/NixOS/nixpkgs/archive/bc260badaebf67442befe20fb443034d3a91f2b3.tar.gz
#!nix-shell -i bash -p html-tidy saxonb jq

set -e

export IPFS_PATH=/data/ipfs/repo

TIMESTAMP=$(date --utc --rfc-3339=seconds | sed -e 's/ /T/')
HTML=../data/raw/$TIMESTAMP.html
JSON=../data/json/$TIMESTAMP.json

echo Timestamp: $TIMESTAMP

curl -s -o "$HTML" https://www.eia.gov/todayinenergy/prices.php

CID=$(ipfs add -q "$HTML" | sed -e 's/^added \(.*\) .*$/\1/')

echo CID: $CID

sed -e '/fb:like/d' "$HTML"                            | \
tidy -quiet -numeric -asxml 2>/dev/null                | \
saxonb - eia-daily-prices.xsl ts="$TIMESTAMP" cid=$CID > tmp.json


curl -s 'https://markets.newyorkfed.org/api/rates/secured/sofr/last/1.json' | \
jq '{"247427" : .refRates[] | { (.type) : { "effectiveDate" : .effectiveDate , "percentRate" : (.percentRate | tostring ), "source" : "https://markets.newyorkfed.org" } } }' | \
jq -s add - tmp.json > $JSON


less $JSON


DIR_CID=$(ipfs add -q -r ../data | tail -n 1)

ipfs name publish --key=mantis /ipfs/$DIR_CID


NETWORK=mainnet

export CARDANO_NODE_SOCKET_PATH=$HOME/.local/share/Daedalus/$NETWORK/cardano-node.socket

gpg -d payment.skey.gpg | ./mantis $NETWORK.mantis --metadata $JSON
