Statistic on Minting Metadata for NFTs, 10 April 2021
=====================================================

Below are summarized the statistics (filtered for brevity) for minting metadata of NFTs currently on the blockchain.

*One important item that is noticeably missing is that almost none of the metadata has a link (IPFS or otherwise) to the monetary policy script (not just its hash): without access to view that script, it is impossible to audit the NFT to verify that it really is an NFT (i.e., that there is only one and that no more can ever be minted).*


Token Statistics
----------------

| Metric                      | Value |
|-----------------------------|------:|
| Distinct Policies           |  1328 |
| Distinct Assets             | 30956 |
| Pseudo-NFTs                 | 27993 |
| NFTs                        | 27726 |
| NFTs with Minting Metadata  | 27785 |
| Conforming NFTs (see below) | 16655 |

(In the above, "pseudo-NFTs" are tokens that currently have one in existence, but previously had more than one that were then burned.)


Prevalence of Metadata Keys in NFT Minting
------------------------------------------

| Metadata Key | NFTs  |
|-------------:|------:|
|          721 | 27146 |
|            0 |   440 |
|       787084 |    85 |
|            1 |    22 |
|       815159 |    18 |


Prevalence of JSON Keys in NFT Minting Metadata
-----------------------------------------------

| JSON Key          | Prevalence [%] |
|-------------------|---------------:|
| name              |          95.59 |
| image             |          95.36 |
| arweaveId         |          37.95 |
| type              |          36.85 |
| traits            |          36.10 |
| description       |          31.30 |
| properties        |          30.47 |
| tags              |          30.41 |
| value             |          30.39 |
| key               |          30.39 |
| creator           |          30.37 |
| publisher         |          23.98 |
| id                |          20.55 |
| version           |          20.35 |
| copyright         |          20.08 |
| ipfs              |           4.29 |
| url               |           3.91 |
| tokens            |           3.91 |
| asset             |           3.91 |
| policyId          |           3.90 |
| cnftFormatVersion |           3.90 |
| mimeType          |           2.52 |
| longDescription   |           2.52 |
| assetType         |           2.52 |
| assetHash         |           2.52 |
| assetDescription  |           2.52 |
| artistName        |           2.52 |
| gallery           |           2.51 |
| collectionName    |           2.15 |
| longitude         |           2.12 |
| latitude          |           2.12 |
| location          |           0.40 |
| color             |           0.37 |
| Rarity            |           0.35 |
| Copyright         |           0.35 |
| collection        |           0.34 |
| attributes        |           0.34 |


"Conforming" Tokens
-------------------
Over half of the tokens conform to the following metadata pattern:

    {
      "721" : {
        "<policy hash>" : {
          "<asset name>" : {
            . . .
          }
          . . .
        }
        . . .
      }
    }

Among these "conforming" tokens, there is the following prevalence of JSON keys describing the asset:

| JSON Key          | Prevalence [%] |
|-------------------|---------------:|
| name              |          92.65 |
| image             |          92.26 |
| type              |          51.04 |
| description       |          50.73 |
| properties        |          49.75 |
| tags              |          49.65 |
| value             |          49.64 |
| key               |          49.63 |
| creator           |          49.63 |
| publisher         |          38.57 |
| id                |          32.76 |
| version           |          32.56 |
| copyright         |          32.03 |
| ipfs              |           6.53 |
| url               |           6.52 |
| tokens            |           6.51 |
| policyId          |           6.51 |
| asset             |           6.51 |
| cnftFormatVersion |           6.50 |
| mimeType          |           4.21 |
| assetHash         |           4.21 |
