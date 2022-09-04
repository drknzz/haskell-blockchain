module Utils where

fromEither :: Either a a -> a
fromEither = either id id

isJust :: Maybe a -> Bool
isJust = maybe False (const True)

fromMaybe :: a -> Maybe a -> a
fromMaybe def = maybe def id

maybeHead :: [a] -> Maybe a
maybeHead (x : _) = Just x
maybeHead _ = Nothing
