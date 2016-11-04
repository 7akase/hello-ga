{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeSynonymInstances #-}

import Data.Char (chr, ord)
import Data.List (foldl')
import System.Random (mkStdGen, random, randoms)
import System.IO (IOMode(..), hClose, hGetContents, openFile)

import GA (Entity(..), GAConfig(..), Archive(..), evolveVerbose)

type Model = Double -- Entity
type SNR   = Double -- Score
type Dset  = Double -- Dataset to calculate score
type Pool  = Double -- Pool to generate new entity

instance Entity Model SNR Dset Pool IO where
  genRandom pool seed = return $ fromIntegral n 
    where
      g = mkStdGen seed
      n = (fst $ random g :: Int) `mod` 101

  crossover _ _ seed e1 e2 = return $ Just e
    where
      e = (e1 + e2) / 2
 
  mutation pool p seed e = return $ Just (fromIntegral n) 
    where
      g = mkStdGen seed
      n = (fst $ random g :: Int) `mod` 101
      
  score d e = do
    return $ Just $ abs (e - d) 

  isPerfect (_, s) = s == 0.0

main :: IO()
main = do
  let cfg = GAConfig
              10   -- population size
              25    -- archive size (best entities to keep track of)
              300   -- maximum number of generations
              0.8   -- crossover rate (% of entities by crossover)
              0.2   -- mutation rate (% of entities by mutation)
              0.0   -- parameter for crossover (not used here)
              0.2   -- parameter for mutation (% of replaced letters)
              False -- whether or not to use checkpointing
              False -- don't rescore archive in each generation

  let g       = mkStdGen 0 -- random generator
  let pool    = (0.0  :: Pool)  -- answer 
  let dataset = (23.0 :: Dset)  -- target
 
  es <- evolveVerbose g cfg pool dataset :: IO(Archive Model SNR)
  let e = snd $ head es -- get the best entity and it's score

  putStrLn $ "best entity (GA): " ++ (show e)
