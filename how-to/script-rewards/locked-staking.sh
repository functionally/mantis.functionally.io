# An "investor" contributes 1000 ADA to a time-locked
# script that pays its staking rewards to a "rewardee".
# In lieu of receiving those staking rewards, the
# rewardee contributes 10 ADA to the script. Only the
# investor can redeem the funds from the script, and
# only after 2 epochs have passed.


# Choose `testnet` or `mainnet`.

NETWORK=testnet


# Set the network magic appropriately.

case $NETWORK in
  mainnet)
    CLI_MAGIC="--mainnet"
    API_MAGIC="Mainnet"
    ;;
  *)
    CLI_MAGIC="--testnet-magic 1097911063"
    API_MAGIC="Testnet $ NetworkMagic 1097911063"
    ;;
esac


# The investor needs to have a verification key and
# a signing key so they can retrieve funds from the
# script. We can generate these here, or they can be
# extracted from an existing address using the
# `cardano-address` command. This key only needs to
# be used once, when the funds are withdrawn from
# the script.

cardano-cli address key-gen \
  --verification-key-file redemption.vkey \
  --signing-key-file      redemption.skey


# The receiver of the staking rewards also needs to
# have a verification key and a signing key. We could
# generate new ones and then delegate to a stakepool
# with them, but it is simpler just to use a stake
# address that is already associated with a wallet.
# See <https://docs.cardano.org/projects/cardano-node/en/latest/stake-pool-operations/keys_and_addresses.html#stake-key-pair>
# for instructions on generating staking keys and
# and addresses. Importantly, if a fresh stake
# address is generated, it must be delegated to
# a stakepool using the command
# `cardano-cli stake-address delegation-certificate`
# to generate a certificate that must then be manually
# submitted in a transaction to the network. Otherwise,
# no rewards will be received!

STAKE_ADDR=stake1uyx07tvec6fuff78s7v456fx94ukmpvh4x6tynjhmqwta8c09uy75


# Because we want to prevent the funds from being
# withdrawn from the script until a future time,
# we need to compute the slot number corresponding
# to that time. There are 432,000 slots per epoch.
# The following command shows the current slot
# number. In this example, we'll just wait 2 epochs.

cardano-cli query tip $CLI_MAGIC

EPOCHS=2
NOW=$(cardano-cli query tip $CLI_MAGIC | sed -n -e '/slotNo/{s/^.*: \(.*\)$/\1/; p}')
SLOTS_PER_EPOCH=432000
ENDING=$((NOW + EPOCHS * SLOTS_PER_EPOCH))


# We place the hash of the redemption verification key
# into the script and time-lock the script.

cardano-cli address key-hash \
  --payment-verification-key-file redemption.vkey \
  > redemption.hash
REDEMPTION_HASH=$(cat redemption.hash)

cat << EOI > script.json
{
  "type" : "all"
, "scripts" : [
    {
      "type"    : "sig"
    , "keyHash" : "$REDEMPTION_HASH"
    }
  , {
      "type" : "after"
    , "slot" : $ENDING
    }
  ]
}
EOI


# The hash of the script acts like the hash of
# a payment verification key.

cardano-cli transaction policyid \
  --script-file script.json \
  > script.hash
SCRIPT_HASH=$(cat script.hash)


# Now combine the script hash with the stake address to form
# an address for the script.

runghc -XOverloadedStrings > script.addr << EOI
import Cardano.Api
import Cardano.Api.Shelley
import Shelley.Spec.Ledger.Credential
main :: IO ()
main =
  let
    Right (StakeAddress _ stakeAddr) = deserialiseFromBech32 AsStakeAddress "$STAKE_ADDR"
    Just scriptHash = deserialiseFromRawBytesHex AsScriptHash "$SCRIPT_HASH"
    addr = AddressShelley
      $ ShelleyAddress
        (toShelleyNetwork $ $API_MAGIC)
        (ScriptHashObj $ toShelleyScriptHash scriptHash)
        (StakeRefBase stakeAddr)
  in
    putStrLn . init . tail . show $ serialiseAddress addr
EOI
SCRIPT_ADDR=$(cat script.addr)


# Now we need to fund the script. In this example, the investor
# will send 1000 ADA and the reward-receiver will send 10 ADA
# and also pay a 0.5 ADA transaction fee. We've contrived to have
# the following UTxOs in each of their wallets with the exact
# amounts needed, 1000 and 10.5 ADA, respectively.


# The investor funds the script from one of the UTxOs in their wallet.

INVESTOR_ADDR=addr_test1qq9prvx8ufwutkwxx9cmmuuajaqmjqwujqlp9d8pvg6gupcvluken35ncjnu0puetf5jvttedkze02d5kf890kquh60slacjyp

cardano-cli query utxo $CLI_MAGIC --mary-era --address $INVESTOR_ADDR
#                            TxHash                                TxIx Amount
# -----------------------------------------------------------------------------------------
# 5f9cbe32eb27b2c21d3f20efa201a8a17d2e41276bb2e4a4007fd6e95f2d0e80    0 1000000000 lovelace

INVESTOR_UTXO='5f9cbe32eb27b2c21d3f20efa201a8a17d2e41276bb2e4a4007fd6e95f2d0e80#0'


# The rewardee funds the script from one of the UTxOs in their wallet.

REWARDEE_ADDR=addr_test1vzeetsdfgex5r8rf6pwpfzse63qnpsjf40aejrr28lxskpcv5y9j7

cardano-cli query utxo $CLI_MAGIC --mary-era --address $REWARDEE_ADDR
#                            TxHash                                TxIx Amount
# ---------------------------------------------------------------------------------------
# 28be1f1e09889f386ad9ffadf792727c4f7d5c73fd586c16e8b2f7c34075a884    0 10500000 lovelace

REWARDEE_UTXO='28be1f1e09889f386ad9ffadf792727c4f7d5c73fd586c16e8b2f7c34075a884#0'


# Now build the transaction using these UTxOs as input and the
# script as output.

cardano-cli transaction build-raw --mary-era \
  --tx-in $INVESTOR_UTXO \
  --tx-in $REWARDEE_UTXO \
  --tx-out $SCRIPT_ADDR+1010000000 \
  --fee 500000 \
  --out-file tx-initial.raw


# The investor witnesses the transaction with the signing key
# for the UTxO they are contributing.

cardano-cli transaction witness $CLI_MAGIC \
  --signing-key-file investor.skey \
  --tx-body-file tx-initial.raw \
  --out-file tx-initial.investor-witness


# The rewardee witnesses the transaction with the signing key
# for the UTxO they are contributing.

cardano-cli transaction witness $CLI_MAGIC \
  --signing-key-file rewardee.skey \
  --tx-body-file tx-initial.raw \
  --out-file tx-initial.rewardee-witness


# The separate witnesses are assembled into a signed transaction
# and submitted.

cardano-cli transaction assemble \
  --tx-body-file tx-initial.raw \
  --witness-file tx-initial.investor-witness \
  --witness-file tx-initial.rewardee-witness \
  --out-file tx-initial.signed

cardano-cli transaction submit $CLI_MAGIC \
  --tx-file tx-initial.signed


# The funds are now at the script address.

cardano-cli query utxo $CLI_MAGIC --mary-era \
  --address $SCRIPT_ADDR
#                            TxHash                                TxIx Amount
# -----------------------------------------------------------------------------------------
# e591aa4f83ba959051c05cd035e0351fb75eff0abc1dda6c00dc8c229986c8b5    0 1010000000 lovelace

SCRIPT_UTXO='e591aa4f83ba959051c05cd035e0351fb75eff0abc1dda6c00dc8c229986c8b5#0'


# We can build the transaction for the investor to redeem the
# funds from the script. It is signed with the redemption key
# but sent to an address in the investor's wallet.

cardano-cli transaction build-raw --mary-era \
  --invalid-before $ENDING \
  --tx-in $SCRIPT_UTXO \
  --tx-out $INVESTOR_ADDR+1009800000 \
  --fee 200000 \
  --out-file tx-final.raw

cardano-cli transaction sign $CLI_MAGIC \
  --signing-key-file redemption.skey \
  --script-file script.json \
  --tx-body-file tx-final.raw \
  --out-file tx-final.signed


# If this transaction is submitted too early, then a
# `LedgerFailure` error is occurs, but the transaction
# can be resubmitted after the required number of slots
# have passed.

cardano-cli transaction submit $CLI_MAGIC \
  --tx-file tx-final.signed
