{-# LANGUAGE OverloadedStrings, ScopedTypeVariables #-}

-----------------------------------------------------------------------------
-- |
-- Module      : Hoodle.Config 
-- Copyright   : (c) 2011, 2012 Ian-Woo Kim
--
-- License     : BSD3
-- Maintainer  : Ian-Woo Kim <ianwookim@gmail.com>
-- Stability   : experimental
-- Portability : GHC
--
-----------------------------------------------------------------------------

module Hoodle.Config where

import Control.Monad
import Data.Configurator as C
import Data.Configurator.Types 
import System.Environment 
import System.Directory
import System.FilePath
import Control.Concurrent 

emptyConfigString :: String 
emptyConfigString = "\n#config file for hoodle \n "  

loadConfigFile :: IO Config
loadConfigFile = do 
  homepath <- getEnv "HOME" 
  let dothoodle = homepath </> ".hoodle"
  b <- doesFileExist dothoodle
  when (not b) $ do 
    writeFile dothoodle emptyConfigString 
    threadDelay 1000000
  config <- load [Required "$(HOME)/.hoodle"]
  return config
  
getMaxUndo :: Config -> IO (Maybe Int)
getMaxUndo c = C.lookup c "maxundo"

getPenDevConfig :: Config -> IO (Maybe String, Maybe String,Maybe String) 
getPenDevConfig c = do 
  mcore <- C.lookup c "core"
  mstylus <- C.lookup c "stylus" 
  meraser <- C.lookup c "eraser"
  return (mcore,mstylus,meraser)
  
getXInputConfig :: Config -> IO Bool 
getXInputConfig c = do 
  (mxinput :: Maybe String) <- C.lookup c "xinput"
  case mxinput of
    Nothing -> return False
    Just str -> case str of 
                  "true" -> return True
                  "false" -> return False 
                  _ -> error "cannot understand xinput in configfile"

{-
getNetworkInfo :: Config -> IO (Maybe HoodleClipClientConfiguration)
getNetworkInfo c = do 
  (mserver :: Maybe String) <- C.lookup c "network.server"
  (mclient :: Maybe String) <- C.lookup c "network.client"
  return (HoodleClipClientConfiguration <$> mserver <*> mclient)
-}
