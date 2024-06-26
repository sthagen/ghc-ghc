{-# LANGUAGE CPP #-}
{-# LANGUAGE MagicHash #-}
{-# LANGUAGE UnboxedTuples #-}
module Main where

#include "MachDeps.h"

import GHC.Ptr(Ptr(..), nullPtr, plusPtr, minusPtr)
import GHC.Stable(
  StablePtr(..), castStablePtrToPtr, castPtrToStablePtr, newStablePtr)
import GHC.Exts
import Data.Char(ord)
import GHC.Int
import GHC.Word
import GHC.IO

assertEqual :: (Show a, Eq a) => String -> a -> a -> IO ()
assertEqual msg a b
  | a /= b = putStrLn (msg ++ " " ++ show a ++ " /= " ++ show b)
  | otherwise = return ()

readBytes :: MutableByteArray# s -> State# s -> Int# -> (# State# s, [Word8] #)
readBytes marr s0 len = go s0 len []
 where
  go s 0# bs = (# s, bs #)
  go s i  bs = case readWord8Array# marr (i -# 1#) s of
    (# s', b #) -> go s' (i -# 1#) (W8# b : bs)

indexBytes :: Addr# -> Int# -> [Word8]
indexBytes arr len =
  [W8# (indexWord8OffAddr# arr i) | I# i <- [0..I# len - 1]]

test :: (Eq a, Show a)
  => String
  -> (Addr# -> Int# -> a)
  -> (Addr# -> Int# -> State# RealWorld
      -> (# State# RealWorld, a #))
  -> (Addr# -> Int# -> a -> State# RealWorld
      -> State# RealWorld)
  -> a
  -> [Word8]
  -> Int
  -> IO ()
test name index read write val valBytes len = do
  putStrLn name
  mapM_ testAtOffset [0..16]
 where
  arrLen :: Int#
  arrLen = 24#

  fillerByte :: Word8
  fillerByte = 0x34

  expectedArrayBytes :: Int -> [Word8]
  expectedArrayBytes offset =
       replicate offset fillerByte
    ++ valBytes
    ++ replicate (fromIntegral $ I# arrLen - len - offset) fillerByte

  testAtOffset :: Int -> IO ()
  testAtOffset offset@(I# offset#) = IO (\s0 -> let
    !(# s1, marr #) = newPinnedByteArray# arrLen s0
    !s2 = setByteArray# marr 0# arrLen (case fromIntegral fillerByte of I# i# -> i#) s1
    !addr = mutableByteArrayContents# marr
   in keepAlive# marr s2 (\s2 -> let
      !s3 = write addr offset# val s2
      !(# s4, readOpResult #) = read addr offset# s3
      !(# s5, bytesAfterWrite #) = readBytes marr s4 arrLen
      !(# s6, arr #) = unsafeFreezeByteArray# marr s5
      -- we want to tie the index operations to the State# token so that they happen after the mutations
      !addrFrozen = byteArrayContents# arr
      bytesViaAddrAfterWrite = indexBytes addrFrozen arrLen
      indexOpResult = index addrFrozen offset#
     in
        unIO (do
           assertEqual "readOpResult" readOpResult val
           assertEqual "indexOpResult" indexOpResult val
           assertEqual "bytesAfterWrite indexed" bytesAfterWrite (expectedArrayBytes offset)
           assertEqual "bytesViaAddrAfterWrite indexed" bytesViaAddrAfterWrite (expectedArrayBytes offset)) s6
        )
    )

intToBytes :: Word64 -> Int -> [Word8]
intToBytes (W64# val0) (I# len0) = let
    result = go val0 len0
    go v 0# = []
    go v len =
      W8# (wordToWord8# (word64ToWord# v)) : go (v `uncheckedShiftRL64#` 8#) (len -# 1#)
  in
#if defined(WORDS_BIGENDIAN)
    reverse result
#else
    result
#endif

testIntArray :: (Eq a, Show a, Integral a, Num a)
  => String
  -> (Addr# -> Int# -> a)
  -> (Addr# -> Int# -> State# RealWorld
      -> (# State# RealWorld, a #))
  -> (Addr# -> Int# -> a -> State# RealWorld
      -> State# RealWorld)
  -> a
  -> Int
  -> IO ()
testIntArray name0 index read write val0 len = do
  doOne (name0 ++ " positive") val0
  doOne (name0 ++ " negative") (negate val0)
 where
  doOne name val = test name index read write
    val (intToBytes (fromIntegral val) len) len

testWordArray :: (Eq a, Show a, Integral a)
  => String
  -> (Addr# -> Int# -> a)
  -> (Addr# -> Int# -> State# RealWorld
        -> (# State# RealWorld, a #))
  -> (Addr# -> Int# -> a -> State# RealWorld
        -> State# RealWorld)
  -> a
  -> Int
  -> IO ()
testWordArray name index read write val len =
  test name index read write
    val (intToBytes (fromIntegral val) len) len

wordSizeInBytes :: Int
wordSizeInBytes = WORD_SIZE_IN_BITS `div` 8

int :: Int
int
  | WORD_SIZE_IN_BITS == 32 = 12345678
  | otherwise = 1234567890123

word :: Word
word = fromIntegral int

float :: Float
float = 123.456789

-- Test pattern generated by this python code:
-- >>> import struct
-- >>> import binascii
-- >>> binascii.hexlify(struct.pack('>f', 123.456789))
floatBytes :: Word64
floatBytes = 0x42f6e9e0

double :: Double
double = 123.45678901234

-- Test pattern generated by this python code:
-- >>> import struct
-- >>> import binascii
-- >>> binascii.hexlify(struct.pack('>d', 123.45678901234))
doubleBytes :: Word64
doubleBytes = 0x405edd3c07fb4b09

main :: IO ()
main = do
  testIntArray "Int8#"
    (\arr i -> I8# (indexInt8OffAddr# arr i))
    (\arr i s -> case readInt8OffAddr# arr i s of (# s', a #) -> (# s', I8# a #))
    (\arr i (I8# a) s -> writeInt8OffAddr# arr i a s)
    123 1
  testIntArray "Int16#"
    (\arr i -> I16# (indexWord8OffAddrAsInt16# arr i))
    (\arr i s -> case readWord8OffAddrAsInt16# arr i s of (# s', a #) -> (# s', I16# a #))
    (\arr i (I16# a) s -> writeWord8OffAddrAsInt16# arr i a s)
    12345 2
  testIntArray "Int32#"
    (\arr i -> I32# (indexWord8OffAddrAsInt32# arr i))
    (\arr i s -> case readWord8OffAddrAsInt32# arr i s of (# s', a #) -> (# s', I32# a #))
    (\arr i (I32# a) s -> writeWord8OffAddrAsInt32# arr i a s)
    12345678 4
  testIntArray "Int64#"
    (\arr i -> I64# (indexWord8OffAddrAsInt64# arr i))
    (\arr i s -> case readWord8OffAddrAsInt64# arr i s of (# s', a #) -> (# s', I64# a #))
    (\arr i (I64# a) s -> writeWord8OffAddrAsInt64# arr i a s)
    1234567890123 8
  testIntArray "Int#"
    (\arr i -> I# (indexWord8OffAddrAsInt# arr i))
    (\arr i s -> case readWord8OffAddrAsInt# arr i s of (# s', a #) -> (# s', I# a #))
    (\arr i (I# a) s -> writeWord8OffAddrAsInt# arr i a s)
    int wordSizeInBytes

  testWordArray "Word8#"
    (\arr i -> W8# (indexWord8OffAddr# arr i))
    (\arr i s -> case readWord8OffAddr# arr i s of (# s', a #) -> (# s', W8# a #))
    (\arr i (W8# a) s -> writeWord8OffAddr# arr i a s)
    123 1
  testWordArray "Word16#"
    (\arr i -> W16# (indexWord8OffAddrAsWord16# arr i))
    (\arr i s -> case readWord8OffAddrAsWord16# arr i s of (# s', a #) -> (# s', W16# a #))
    (\arr i (W16# a) s -> writeWord8OffAddrAsWord16# arr i a s)
    12345 2
  testWordArray "Word32#"
    (\arr i -> W32# (indexWord8OffAddrAsWord32# arr i))
    (\arr i s -> case readWord8OffAddrAsWord32# arr i s of (# s', a #) -> (# s', W32# a #))
    (\arr i (W32# a) s -> writeWord8OffAddrAsWord32# arr i a s)
    12345678 4
  testWordArray "Word64#"
    (\arr i -> W64# (indexWord8OffAddrAsWord64# arr i))
    (\arr i s -> case readWord8OffAddrAsWord64# arr i s of (# s', a #) -> (# s', W64# a #))
    (\arr i (W64# a) s -> writeWord8OffAddrAsWord64# arr i a s)
    1234567890123 8
  testWordArray "Word#"
    (\arr i -> W# (indexWord8OffAddrAsWord# arr i))
    (\arr i s -> case readWord8OffAddrAsWord# arr i s of (# s', a #) -> (# s', W# a #))
    (\arr i (W# a) s -> writeWord8OffAddrAsWord# arr i a s)
    word wordSizeInBytes

  test
    "Char#"
    (\arr i -> C# (indexWord8OffAddrAsChar# arr i))
    (\arr i s ->
        case readWord8OffAddrAsChar# arr i s of (# s', a #) -> (# s', C# a #))
    (\arr i (C# a) s -> writeWord8OffAddrAsChar# arr i a s)
    'z'
    [fromIntegral $ ord 'z']
    1
  test
    "WideChar#"
    (\arr i -> C# (indexWord8OffAddrAsWideChar# arr i))
    (\arr i s ->
        case readWord8OffAddrAsWideChar# arr i s of (# s', a #) -> (# s', C# a #))
    (\arr i (C# a) s -> writeWord8OffAddrAsWideChar# arr i a s)
    '𠜎'  -- See http://www.i18nguy.com/unicode/supplementary-test.html
    (intToBytes (fromIntegral $ ord '𠜎') 4)
    4
  test
    "Addr#"
    (\arr i -> Ptr (indexWord8OffAddrAsAddr# arr i))
    (\arr i s ->
        case readWord8OffAddrAsAddr# arr i s of (# s', a #) -> (# s', Ptr a #))
    (\arr i (Ptr a) s -> writeWord8OffAddrAsAddr# arr i a s)
    (nullPtr `plusPtr` int)
    (intToBytes (fromIntegral word) wordSizeInBytes)
    wordSizeInBytes

  stablePtr <- newStablePtr ()
  test
    "StablePtr#"
    (\arr i ->
        castStablePtrToPtr (StablePtr (indexWord8OffAddrAsStablePtr# arr i)))
    (\arr i s -> case readWord8OffAddrAsStablePtr# arr i s of
                   (# s', a #) -> (# s', castStablePtrToPtr (StablePtr a) #))
    (\arr i p s -> case castPtrToStablePtr p of
                     (StablePtr a) -> writeWord8OffAddrAsStablePtr# arr i a s)
    (castStablePtrToPtr stablePtr)
    (intToBytes (fromIntegral $ castStablePtrToPtr stablePtr `minusPtr` nullPtr)
                wordSizeInBytes)
    wordSizeInBytes

  test
    "Float#"
    (\arr i -> F# (indexWord8OffAddrAsFloat# arr i))
    (\arr i s ->
        case readWord8OffAddrAsFloat# arr i s of (# s', a #) -> (# s', F# a #))
    (\arr i (F# a) s -> writeWord8OffAddrAsFloat# arr i a s)
    float
    (intToBytes floatBytes 4)
    4
  test
    "Double#"
    (\arr i -> D# (indexWord8OffAddrAsDouble# arr i))
    (\arr i s ->
        case readWord8OffAddrAsDouble# arr i s of (# s', a #) -> (# s', D# a #))
    (\arr i (D# a) s -> writeWord8OffAddrAsDouble# arr i a s)
    double
    (intToBytes doubleBytes 8)
    8
