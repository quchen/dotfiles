#!/usr/bin/env stack
{- stack
    --resolver lts-7.13
    --install-ghc
    runghc
    --package cryptonite
    --package pgp-wordlist
    --package text
    --package bytestring
    --package base
    --
    -hide-all-packages
-}


{-# OPTIONS_GHC -Wall -Wcompat #-}

import           Crypto.Random
import qualified Data.ByteString.Lazy  as BSL
import qualified Data.Text.IO          as T
import qualified Data.Text.PgpWordlist as Pgp



main :: IO ()
main = do
    bytes <- getRandomBytes 8
    T.putStrLn (Pgp.toText (BSL.fromStrict bytes))
