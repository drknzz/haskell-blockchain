module PPrint where

writeln :: String -> IO ()
writeln = putStrLn

showsPair :: Show a => (String, a) -> ShowS
showsPair (k, v) = showString k . showString ": " . shows v

pprH, pprV :: [ShowS] -> ShowS
pprV = intercalateS $ showString "\n"
pprH = intercalateS $ showString " "

intercalateS :: ShowS -> [ShowS] -> ShowS
intercalateS _ [] = shows ""
intercalateS sep (x : xs) = x . foldr (\x y -> sep . x . y) (showString "") xs

pprListWith :: (a -> ShowS) -> [a] -> ShowS
pprListWith f l = intercalateS (showString "\n") (map f l)

runShows :: ShowS -> IO ()
runShows = putStrLn . ($ "")
