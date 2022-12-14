import Blockchain
import HashTree
import Hashable32
import PPrint
import Utils

-- |
-- >>> putStr $ drawTree $ buildTree "fubar"
-- 0x2e1cc0e4 -
--   0xfbfe18ac -
--     0x6600a107 -
--       0x00000066 'f'
--       0x00000075 'u'
--     0x62009aa7 -
--       0x00000062 'b'
--       0x00000061 'a'
--   0xd11bea20 +
--     0x7200b3e8 +
--       0x00000072 'r'

-- | Merkle paths and proofs
-- >>> mapM_ print $ map showMerklePath  $ merklePaths 'i' $ buildTree "bitcoin"
-- "<0x5214666a<0x7400b6ff>0x00000062"
-- ">0x69f4387c<0x6e00ad98>0x0000006f"
--
-- >>> buildProof 'i' $ buildTree "bitcoin"
-- Just (MerkleProof 'i' <0x5214666a<0x7400b6ff>0x00000062)
--
-- >>> buildProof 'e' $ buildTree "bitcoin"
-- Nothing
--
-- >>> let t = buildTree "bitcoin"
-- >>> let proof = buildProof 'i' t
-- >>> verifyProof (treeHash t) <$> proof
-- Just True
-- >>> verifyProof 0xbada55bb <$> proof
-- Just False

-- | Chain verification
-- >>> tx1 = Tx{txFrom = hash "Alice", txTo = hash "Bob", txAmount = 1 * coin}
-- >>> block0 = mineBlock (hash "Satoshi") 0 []
-- >>> genesis = block0
-- >>> block1 = mineBlock (hash "Alice") (hash genesis) []
-- >>> block2 = mineBlock (hash "Charlie") (hash block1) [tx1]
-- >>> chain = [block2, block1, genesis]
-- >>> verifyChain [block1, block2]
-- Nothing
--
-- >>> VH <$> verifyChain [block2, block1, block0]
-- Just 0x0dbea380

-- | Transaction Receipts
-- >>> tx1 = Tx{txFrom = hash "Alice", txTo = hash "Bob", txAmount = 1 * coin}
-- >>> genesis = mineBlock (hash "Satoshi") 0 []
-- >>> block1 = mineBlock (hash "Alice") (hash genesis) []
-- >>> charlie = hash "Charlie"
-- >>> (block, [receipt]) = mineTransactions charlie (hash block1) [tx1]
-- >>> block
-- BlockHeader {parent = 797158976, coinbase = Tx {txFrom = 0, txTo = 1392748814, txAmount = 50000}, txroot = 2327748117, nonce = 3}
-- Tx {txFrom = 2030195168, txTo = 2969638661, txAmount = 1000}
-- <BLANKLINE>
--
-- >>> receipt
-- TxReceipt {txrBlock = 230597504, txrProof = MerkleProof (Tx {txFrom = 2030195168, txTo = 2969638661, txAmount = 1000}) >0xbcc3e45a}
-- >>> validateReceipt receipt (blockHdr block)
-- True

-- | Pretty printing
-- >>> tx1 = Tx{txFrom = hash "Alice", txTo = hash "Bob", txAmount = 1 * coin}
-- >>> block0 = mineBlock (hash "Satoshi") 0 []
-- >>> block1 = mineBlock (hash "Alice") (hash block0) []
-- >>> block2 = mineBlock (hash "Charlie") (hash block1) [tx1]
-- >>> runShows $ pprBlock block2
-- hash: 0x0dbea380
-- parent: 0x2f83ae40
-- miner: 0x5303a90e
-- root: 0x8abe9e15
-- nonce: 3
-- Tx# 0xbcc3e45a from: 0000000000 to: 0x5303a90e amount: 50000
-- Tx# 0x085e2467 from: 0x790251e0 to: 0xb1011705 amount: 1000
--
-- >>> runShows $ pprListWith pprBlock [block0, block1, block2]
-- hash: 0x70b432e0
-- parent: 0000000000
-- miner: 0x7203d9df
-- root: 0x5b10bd5d
-- nonce: 18
-- Tx# 0x5b10bd5d from: 0000000000 to: 0x7203d9df amount: 50000
-- hash: 0x2f83ae40
-- parent: 0x70b432e0
-- miner: 0x790251e0
-- root: 0x5ea7a6f0
-- nonce: 0
-- Tx# 0x5ea7a6f0 from: 0000000000 to: 0x790251e0 amount: 50000
-- hash: 0x0dbea380
-- parent: 0x2f83ae40
-- miner: 0x5303a90e
-- root: 0x8abe9e15
-- nonce: 3
-- Tx# 0xbcc3e45a from: 0000000000 to: 0x5303a90e amount: 50000
-- Tx# 0x085e2467 from: 0x790251e0 to: 0xb1011705 amount: 1000
main = return ()
