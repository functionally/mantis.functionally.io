Novel Use Cases for Staking
===========================

These use cases rely on the facts that (a) payment credentials can be arbitrarily combined with stake credentials, (b) payment or stake credentials can belong either to a wallet or a script, and (c) only verification credentials are needed to construct addresses.

None of the current wallets support such use cases, and a user interface to construct them would be a little complex. However, all of the use cases that just involve Allegra scripts are possible on the current mainnet, and `cardano-cli` supports most of them.


Staking to a "foreign" address
------------------------------

One example of this might be the situation where one doesn't want to collect staking rewards because they have adverse taxation implications in one's jurisdiction. To do this, one combines one's own payment verification key with (for instance) a charity's stake verification key into an address to which one sends ADA. (Building this address doesn't require the stake secret key.) One can later spend the UTxO at this address because one possesses the payment secret key, but all of the staking rewards from the address accrue to the charity. One would not have a tax liability for these rewards because one never has the ability to withdraw them for oneself.


Deferring access to staking rewards
-----------------------------------

Another example that manipulates tax liability would be to have a time-locked Allegra script receive staking rewards. The script could be constructed so that one can freely add and remove funds from it, but the staking rewards could only be redeemed after a fixed amount of time. One could use this to defer stake income until a future tax year or bundle rewards from multiple epochs into a single reward. A smart contract connected to an oracle could even automatically release the funds at the most tax-advantaged time.


Retaining staking rights for ADA sent in a transaction
------------------------------------------------------

One could also retain the staking rewards for ADA sent to a script or smart contract by sending the transaction to the address constructed from the script's payment verification credentials but with one's own stake verification key. Of course, as soon as the script or contract spent the UTxO, one would no longer receive the stake rewards, but some scripts and contracts might hold funds for a long time.


Locking-in fixed rewards from a stake pool
------------------------------------------

If the stakepool is willing to provide a fixed rate for the reward (instead of the variable rate that results from the unpredictability in blocks being assigned to the stakepool each epoch), a simple Marlowe contract or Allegra script would suffice.

For example, the "investor" would contribute 1000 ADA to the contract script and the stakepool would contribue 10 ADA to the script at the start of the contract period. Those 1010 ADA would be locked into the script for 10 epochs and payable only to the investor at the end of the 10 epochs. The stakepool would hold the staking keys for the script and all of the staking rewards of the 1010 ADA in the script would acrue to the stakepool operator (not to the investor, who will receive the extra 10 ADA in lieu of the actual rewards amount). The stakepool operator would benefit by having certainty that the ADA would stay staked for the 10 epochs, while the investor wouldn't experience the variability of epoch-to-epoch rewards or be exposed to the risk of the stakepool being retired. (Such a contract might alleviate investors' concern and confusion about the high variability of epoch-to-epoch rewards from very small pools.)

The current mainnet supports a clunky version of this contract right now. One would have to create the initial transaction with 1000 ADA from the investor and 10 ADA from the stakepool operator, and then each party would have to sign the transaction before it was submitted to a simple Allegra script that [time-locks the ADA](https://docs.cardano.org/projects/cardano-node/en/latest/reference/simple-scripts.html#time-locking) and only lets the investor redeem it. The output address for this transaction would combine the payment verification key for the script with the stake verification key into a script address: since `cardano-cli` [does not yet support constructing script addresses that stake](https://github.com/input-output-hk/cardano-node/blob/7de9c40a43d582d67391bf4c48aec13cf4ab3bc4/cardano-cli/src/Cardano/CLI/Shelley/Run/Address.hs#L228-L229), one would have to write a short program to compute the stakeable script address. At the end of the 10 epochs, the investor could submit the transaction that removes the UTxO from the script. The clunkiness comes from the investor needing to use `cardano-cli` to sign the initial and final transactions.

Variable-rate and multi-period staking contracts like this would be possible with Marlowe or Plutus if one is willing to involve an oracle that monitors staking rewards. One could also construct contracts that didn't require the stakepool operator to add the reward to the initial contract.

See [Locking ADA for Staking](script-rewards/ReadMe.md) for implementation and examples.
