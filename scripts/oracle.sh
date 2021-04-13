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

CID=$(ipfs add --quiet --pin=false "$HTML" | sed -e 's/^added \(.*\) .*$/\1/')

echo CID: $CID

sed -e '/fb:like/d' "$HTML"                            | \
tidy -quiet -numeric -asxml 2>/dev/null                | \
saxonb - eia-daily-prices.xsl ts="$TIMESTAMP" cid=$CID > energy.json


curl -s 'https://markets.newyorkfed.org/api/rates/secured/sofr/last/1.json'  \
| jq '.refRates[] | { (.type) : { "effectiveDate" : .effectiveDate , "percentRate" : (.percentRate | tostring ), "source" : "https://markets.newyorkfed.org" } }' \
> sofr-spot.json

curl -H "x-rapidapi-key: $(cat rapidapi.secret)" \
     -H "x-rapidapi-host: apidojo-yahoo-finance-v1.p.rapidapi.com" \
     -H "useQueryString: true" \
     -s 'https://apidojo-yahoo-finance-v1.p.rapidapi.com/market/v2/get-quotes?region=US&symbols=SR1J21.CME,SR1K21.CME,SR1M21.CME,SR1N21.CME,SR1Q21.CME,SR1U21.CME,SR1V21.CME,SR1X21.CME,SR1Z21.CME,SR1F22.CME,SR1G22.CME,SR1H22.CME,SR3H21.CME,SR3M21.CME,SR3U21.CME,SR3Z21.CME,SR3H22.CME,SR3M22.CME,SR3U22.CME,SR3Z22.CME,SR3H23.CME,SR3M23.CME,SR3U23.CME,SR3Z23.CME' \
| jq '{ Timestamp : "'$TIMESTAMP'" , "Processor" : "https://mantis.functionally.io/mantis.metadata.json" , Schema : "https://mantis.functionally.io/schema/247427/v1.json" , "SOFR_1MONTH" : [ .quoteResponse.result | .[] | select(.underlyingSymbol == "SR1.CME") | { (.symbol) : { settle : .expireIsoDate[0:10], open : (.regularMarketOpen | tostring) } } ] | add  , "SOFR_3MONTH" : [ .quoteResponse.result | .[] | select(.underlyingSymbol == "SR3.CME") | { (.symbol) : { settle : .expireIsoDate[0:10], open : (.regularMarketOpen | tostring) } } ] | add  }' \
| sed -e 's/SR.F/JAN20/;s/SR.G/FEB20/;s/SR.H/MAR20/;s/SR.J/APR20/;s/SR.K/MAY20/;s/SR.M/JUN20/;s/SR.N/JUL20/;s/SR.Q/AUG20/;s/SR.U/SEP20/;s/SR.V/OCT20/;s/SR.X/NOV20/;s/SR.Z/DEC20/;s/\.CME//' \
> sofr-futures.json

jq -s '{"247427" : add}' sofr-spot.json sofr-futures.json > sofr.json


jq -s add energy.json sofr.json > $JSON

less $JSON


DIR_CID=$(ipfs add --quiet --pin=false --recursive ../data | tail -n 1)

ipfs name publish --key=mantis /ipfs/$DIR_CID

curl -X POST                                                                 \
  -H "pinata_api_key:$(cat pinata.key)"                                      \
  -H "pinata_secret_api_key:$(cat pinata.secret)"                            \
  -H "Content-Type: application/json"                                        \
  --data '{"hashToPin": "'$DIR_CID'", "pinataMetadata": {"name": "mantis"}}' \
  https://api.pinata.cloud/pinning/pinByHash


NETWORK=mainnet

export CARDANO_NODE_SOCKET_PATH=$HOME/.local/share/Daedalus/$NETWORK/cardano-node.socket

gpg -d payment.skey.gpg | ./mantis transact $NETWORK.mantis --metadata $JSON
