{-# LANGUAGE ScopedTypeVariables #-}
module T8450 where

runEffect :: Either Bool r -> r
runEffect = undefined

run :: forall a. a
run = runEffect $ (undefined :: Either a ())

{-
r:=a
Expected: Either Bool a
Actual:   Either a ()
-}
