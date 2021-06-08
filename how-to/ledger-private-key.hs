-- Script for computing Ledger Nano X root private key from a seed.


{-# LANGUAGE BinaryLiterals    #-}
{-# LANGUAGE OverloadedStrings #-}


module Main (
  main
) where


import Control.Monad (when)
import Data.Bits ((.|.), (.&.))

-- From the cryptonite package.
import Crypto.Hash (Digest)
import Crypto.Hash.Algorithms (SHA256, SHA512)
import Crypto.MAC.HMAC (Context, finalize, hmac, hmacGetDigest, initialize, update)

-- From the `memory` package.
import qualified Data.ByteArray as BA

-- From the `base16-bytestring` package.
import qualified Data.ByteString.Base16 as Base16

-- From the `bytestring` package.
import qualified Data.ByteString as BS
import qualified Data.ByteString.Char8 as BS8


exampleSeedHex :: String
exampleSeedHex = "4951dc31cc360038d75b70cadb7d7b79f57e2f7b8a960959896e434b43f4b2615bd62dfe15014d0976a34cce62e26c53ed361b27d26d17dbb57b7a58cf19e78e"


exampleRootHex :: BS8.ByteString
exampleRootHex = "e8cf2614c68ee3ac3b8d590214849003c3f88b9c1d5a095f149bee2e5532e3421ae2cd12cb4fb6ee120ce09d24ba73bcd0706a2d582abe9a90238060b368c81d6084283b3600fd5302b1030decaf4ae2e766dfed7b7f3240d4ea52968cbd566d"


ed25519key :: BS8.ByteString
ed25519key = BS8.pack "ed25519 seed" 


main :: IO ()
main =
  do
    putStrLn ""
    putStrLn "Input hexadecimal bytes for seed, or <enter> to use the example:"
    seedHex <- getLine
    Right seed <-
      Base16.decode
        . BS8.pack
        <$> if null seedHex    
              then do
                     putStrLn "Example seed:"
                     putStrLn exampleSeedHex
                     return exampleSeedHex
              else return seedHex
    let
      chainCode =
        BA.unpack
          (
              hmacGetDigest
            . hmac ed25519key
            $ BS.singleton 1 `BS.append` seed
            :: Digest SHA256
          )
      raw = BA.unpack $ hashRepeatedly seed
      private =
           [head raw .&. 248]
        ++ take 30 (tail raw)
        ++ [(.|. 64) . (.&. 63) . last $ take 32 raw]
        ++ drop 32 raw
      root = BS.pack $ private ++ chainCode
      rootHex = Base16.encode root
    putStrLn ""
    putStrLn "Root private key:"
    BS8.putStrLn rootHex
    when (null seedHex)
      $ putStrLn 
      $ if rootHex == exampleRootHex
          then "Correct!"
          else "Incorrect!"


hashRepeatedly :: BA.ByteArrayAccess a
               => a
               -> Digest SHA512
hashRepeatedly =
  let
    go seed =
      let
        seed' = hmacGetDigest $ hmac ed25519key seed
      in
        if (BA.unpack seed' !! 31) .&. 0b00100000 == 0
          then seed'
          else go seed'
  in
    go
