{-# LANGUAGE TypeFamilies #-}

import Prelude hiding (foldr, mapM, sequence)
import Control.Monad hiding (mapM, sequence)
import Data.Traversable



-- the top two of these test main functions work if you remove the DefaultResult and asDefault members of CanBe
--main = sequence $ as putStrLn ["aoeu", "htns"]
main = as (\x -> return x :: IO ()) $ as putStrLn ["aoeu", "htns"]
--main = asDefault $ as putStrLn ["aoeu", "htns"]


-- if you have a function from a to c, then type b can emulate the a, but only if we're allowed to have the function return something other than a straight c (what it returns exactly, is given by the Result type)
class CanBe a b c where
  type Result a b c
--  type DefaultResult a b c
  as :: (a -> c) -> b -> Result a b c
--  asDefault :: b -> DefaultResult a b c

-- any type can trivially emulate itself
instance CanBe a a c where
  type Result a a c = c
--  type DefaultResult a a c = a
  as func = func
--  asDefault arg = arg

-- a functor of a type can emulate that type by fmapping over itself
instance (Functor f) => CanBe a (f a) c where
  type Result a (f a) c = f c
--  type DefaultResult a (f a) c = f a
  as = fmap
--  asDefault arg = arg

-- this one is merely a kludge so that I don't have to use "sequence" in main
-- any iterable structure full of monadic types should be able to map and bind over itself for you
instance (Traversable t, Monad m) => CanBe a (t (m a)) (m c) where
  type Result a (t (m a)) (m c) = m (t c)
--  type DefaultResult a (t (m a)) (m c) = m (t a)
  as func arg = mapM (>>= func) arg
--  asDefault arg = sequence arg