module Main where

import System.Process
import System.Environment

info :: String
info = "info"

init :: Int -> [String] -> IO ()
init 0 _ = putStrLn info
init 1 ["--test"] = putStrLn "--test"
init 1 ["--analitics"] = putStrLn "--analitics"
init 1 [arg] = callCommand ("erl -noshell -s drones main " ++ arg ++ " -s init stop")
init _ _ = putStrLn "\x1B[31merror:\x1B[0m too many arguments"

main :: IO ()
main = getArgs >>= \args -> Main.init (length args) args

-- ghc -O2 -no-keep-hi-files -no-keep-o-files drones.hs

-- ANALITICS DOESN'T RUN IF YOU START IN TERMINAL