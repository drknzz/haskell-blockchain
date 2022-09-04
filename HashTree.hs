module HashTree where

import Data.Either
import Hashable32
import Utils

data Tree a = Leaf Hash a | Twig Hash (Tree a) | Node Hash (Tree a) (Tree a)

leaf :: Hashable a => a -> Tree a
leaf x = Leaf (hash x) x

twig :: Hashable a => Tree a -> Tree a
twig x = Twig (hash (treeHash x, treeHash x)) x

node :: Hashable a => Tree a -> Tree a -> Tree a
node x y = Node (hash (treeHash x, treeHash y)) x y

buildTree :: Hashable a => [a] -> Tree a
buildTree [x] = leaf x
buildTree x = buildTreeFromLeaves (fmap leaf x)

buildTreeFromLeaves :: Hashable a => [Tree a] -> Tree a
buildTreeFromLeaves [x] = twig x
buildTreeFromLeaves [x, y] = node x y
buildTreeFromLeaves x = buildTreeFromLeaves $ buildRow x

buildRow :: Hashable a => [Tree a] -> [Tree a]
buildRow [] = []
buildRow [x] = [twig x]
buildRow (x : y : xs) = node x y : buildRow xs

treeHash :: Tree a -> Hash
treeHash (Leaf x _) = x
treeHash (Twig x _) = x
treeHash (Node x _ _) = x

drawTree :: Show a => Tree a -> String
drawTree x = drawsTree 0 x ""

drawsTree :: Show a => Int -> Tree a -> String -> String
drawsTree t (Leaf x y) s = drawsTabsHash t x $ ' ' : shows y ('\n' : s)
drawsTree t (Twig x y) s = drawsTabsHash t x $ ' ' : '+' : '\n' : drawsTree (t + 2) y s
drawsTree t (Node x y z) s = drawsTabsHash t x $ ' ' : '-' : '\n' : drawsTree (t + 2) y (drawsTree (t + 2) z s)

drawsTabsHash :: Int -> Hash -> String -> String
drawsTabsHash t x = showString (replicate t ' ') . showsHash x

type MerklePath = [Either Hash Hash]

data MerkleProof a = MerkleProof a MerklePath

instance Show a => Show (MerkleProof a) where
  showsPrec d (MerkleProof x y) =
    showParen (d > p) $ showString "MerkleProof " . showsPrec (p + 1) x . showString (' ' : showMerklePath y)
    where
      p = 10

merklePaths :: Hashable a => a -> Tree a -> [MerklePath]
merklePaths x (Leaf h y)
  | hash x == h = [[]]
  | otherwise = []
merklePaths x (Twig h y) = [(Left h) : n | n <- (merklePaths x y)]
merklePaths x (Node h l r) =
  let l1 = [(Left $ treeHash r) : n | n <- (merklePaths x l)]
      r1 = [(Right $ treeHash l) : n | n <- (merklePaths x r)]
   in l1 ++ r1

buildProof :: Hashable a => a -> Tree a -> Maybe (MerkleProof a)
buildProof x y = do
  v <- maybeHead $ merklePaths x y
  return $ MerkleProof x v

showMerklePath :: MerklePath -> String
showMerklePath [] = ""
showMerklePath (x : xs) = showString ((if isRight x then '>' else '<') : (showHash $ fromEither x)) (showMerklePath xs)

verifyProof :: Hashable a => Hash -> MerkleProof a -> Bool
verifyProof h (MerkleProof x y) = h == foldr f (hash x) y
  where
    f = \a b ->
      if isRight a
        then hash (fromEither a, b)
        else hash (b, fromEither a)