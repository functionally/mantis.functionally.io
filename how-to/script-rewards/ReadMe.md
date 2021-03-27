Locking ADA for Staking
=======================

Use Case
--------

An "investor" contributes 1000 ADA to a time-locked script that pays its staking rewards to a "rewardee". In lieu of receiving those staking rewards, the investor receives an extra 10 ADA that the rewardee contributes to the script. Only the investor can redeem the funds from the script, and only after the agreed-upon number of epochs have passed.


Investor Actions
----------------

1.  Create and protect the redemption signing and verification keys.
2.  Witness the initial transaction.
3.  Sign the final transaction.
4.  Submit the final transaction when the time comes to redeem.


Security Considerations
-----------------------

1.  The investor must review and verify the following:
    1.  That the script will only pay to the redemption key.
    2.  That the script locks the funds until the agreed-upon slot.
    3.  That the transaction they initially witness has the script as output and the proper amount of input.
2.  If the investor looses the redemption key (or, equivalently, the final signed transaction), the funds will be lost.


Script with Step-by-Step Details
--------------------------------

See [locked-staking.sh](locked-staking.sh), which requires [cardano-cli](https://github.com/input-output-hk/cardano-node/tree/master/cardano-cli).


Examples on Testnet
-------------------

Brief locking:
*  Duration: 1000 slots.
*  [Transactions](https://explorer.cardano-testnet.iohkdev.io/en/address?address=addr_test1zzcg5w7rmwug9rm80u49mds4jyafp6dqf29w2ajtk2dueusvluken35ncjnu0puetf5jvttedkze02d5kf890kquh60sl6mrts).
*  [Artifacts](short/)


Longer locking:
*  Duration: 2 epochs.
*  [Transactions](https://explorer.cardano-testnet.iohkdev.io/en/address.html?address=addr_test1zq92c9jzqnlxj9ys7erk06lw8m826cj3xhekv6c48qp3trsvluken35ncjnu0puetf5jvttedkze02d5kf890kquh60schyyfn).
*  [Artifacts](long/)



