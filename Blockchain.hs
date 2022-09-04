module Blockchain where

import Control.Monad
import Data.Word
import HashTree
import Hashable32
import PPrint
import Utils

type Address = Hash
type Amount = Word32

coin :: Amount
coin = 1000

data Transaction = Tx
  { txFrom :: Address,
    txTo :: Address,
    txAmount :: Amount
  }
  deriving (Show)

instance Hashable Transaction where
  hash (Tx a b c) = hash [hash a, hash b, hash c]

data Block = Block
  { blockHdr :: BlockHeader,
    blockTxs :: [Transaction]
  }

instance Show Block where
  show (Block hdr txs) = unlines (show hdr : map show txs)

instance Hashable Block where
  hash = hash . blockHdr

data BlockHeader = BlockHeader
  { parent :: Hash,
    coinbase :: Transaction,
    txroot :: Hash, -- root of the Merkle tree
    nonce :: Hash
  }
  deriving (Show)

instance Hashable BlockHeader where
  hash (BlockHeader p c r n) = hash [p, hash c, r, n]

difficulty :: Integer
difficulty = 5

blockReward :: Amount
blockReward = 50 * coin

coinbaseTx :: Address -> Transaction
coinbaseTx miner = Tx {txFrom = 0, txTo = miner, txAmount = blockReward}

validNonce :: BlockHeader -> Bool
validNonce b = (hash b) `mod` (2 ^ difficulty) == 0

type Miner = Address

type Nonce = Word32

mineBlock :: Miner -> Hash -> [Transaction] -> Block
mineBlock miner parent txs = Block (mine miner parent txs 0) txs

mine :: Miner -> Hash -> [Transaction] -> Nonce -> BlockHeader
mine m p t i =
  let cb = coinbaseTx m
      txroot = treeHash $ buildTree $ cb : t
      header = BlockHeader p cb txroot i
   in if validNonce header then header else mine m p t (i + 1)

validChain :: [Block] -> Bool
validChain = isJust . verifyChain

verifyChain :: [Block] -> Maybe Hash
verifyChain [] = Just 0
verifyChain blocks =
  if all (\(x, y) -> isJust $ verifyBlock x $ hash y) (zip blocks (tail blocks))
    then Just $ hash $ head blocks
    else Nothing

verifyBlock :: Block -> Hash -> Maybe Hash
verifyBlock b@(Block hdr txs) parentHash = do
  guard (parent hdr == parentHash)
  guard (txroot hdr == treeHash (buildTree (coinbase hdr : txs)))
  guard (validNonce hdr)
  return (hash b)

data TransactionReceipt = TxReceipt
  { txrBlock :: Hash,
    txrProof :: MerkleProof Transaction
  }
  deriving (Show)

validateReceipt :: TransactionReceipt -> BlockHeader -> Bool
validateReceipt r hdr =
  txrBlock r == hash hdr
    && verifyProof (txroot hdr) (txrProof r)

mineTransactions :: Miner -> Hash -> [Transaction] -> (Block, [TransactionReceipt])
mineTransactions miner parent txs =
  let block = mineBlock miner parent txs
      h = hash block
      tree = buildTree $ (coinbase $ blockHdr block) : txs
   in (block, [TxReceipt h (fromMaybe undefined (buildProof t tree)) | t <- txs])

pprHeader :: BlockHeader -> ShowS
pprHeader self@(BlockHeader parent cb txroot nonce) =
  pprV
    [ p ("hash", VH $ hash self),
      p ("parent", VH $ parent),
      p ("miner", VH $ txTo cb),
      p ("root", VH txroot),
      p ("nonce", nonce)
    ]
  where
    nl = showString "\n"
    p :: Show a => (String, a) -> ShowS
    p = showsPair

pprBlock :: Block -> ShowS
pprBlock (Block header txs) =
  pprHeader header
    . showChar '\n'
    . pprTxs (coinbase header : txs)

pprTx :: Transaction -> ShowS
pprTx tx@(Tx from to amount) =
  pprH
    [ showString "Tx#",
      showsHash (hash tx),
      p ("from", VH from),
      p ("to", VH to),
      p ("amount", amount)
    ]
  where
    p :: Show a => (String, a) -> ShowS
    p = showsPair

pprTxs :: [Transaction] -> ShowS
pprTxs = pprV . map pprTx
