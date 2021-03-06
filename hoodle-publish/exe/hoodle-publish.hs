{-# LANGUAGE DeriveDataTypeable #-}

-----------------------------------------------------------------------------
-- |
-- Module      : Main
-- Copyright   : (c) 2013,2014 Ian-Woo Kim
--
-- License     : GPL-3 
-- Maintainer  : Ian-Woo Kim <ianwookim@gmail.com>
-- Stability   : experimental
-- Portability : GHC
--
-----------------------------------------------------------------------------

module Main where 

import           Control.Applicative ((<$>),(<*>))
import           Control.Monad (filterM)
import           Data.Maybe (isNothing, catMaybes)
import qualified Graphics.UI.Gtk as Gtk (initGUI)
import           System.Console.CmdArgs
import           System.Directory (removeFile)
import           System.Directory.Tree (AnchoredDirTree(..),build,flattenDir)
import           System.FilePath (makeRelative,replaceExtension,(</>))
-- 
import           Hoodle.Publish.PDF
-- 

data HoodlePublish = Publish { urlbase :: String 
                             , rootpath :: FilePath
                             , buildpath :: FilePath
                             , specialurlbase :: String 
                             }
                     deriving (Show,Data,Typeable)

publish :: HoodlePublish 
publish = Publish { urlbase = def &= typ "URLBASE" &= argPos 0 
                  , rootpath = def &= typ "ORIGNALFILEDIR" &= argPos 1 
                  , buildpath = def &= typ "TARGETFILEDIR" &= argPos 2 
                  , specialurlbase = def &= typ "SPECIALURLBASE" 
                  }

mode :: HoodlePublish 
mode = modes [publish] 

-- | 
main :: IO ()
main = do
  Gtk.initGUI 
  params <- cmdArgs mode 
  (_r :/ r') <- build (rootpath params)
  let files = catMaybes . map takeFile . flattenDir $ r' 
      hdlfiles = filter isHdl files 
      pairs = map ((,) <$> id
                   <*> (buildpath params </>) . flip replaceExtension "pdf" . makeRelative (rootpath params)) 
                  hdlfiles 
      swappedpairs = map (\(x,y)->(y,x)) pairs 
  (_b :/ b') <- build (buildpath params)
  let files2 = catMaybes . map takeFile . flattenDir $ b' 
      pdffiles = filter isPdf files2
      willbeerased = filter (\x -> isNothing (lookup x swappedpairs )) pdffiles 
      
  mapM_ removeFile willbeerased 
      
  updatedpairs <- filterM isUpdated pairs 
  mapM_ (createPdf (urlbase params,specialurlbase params) (rootpath params)) updatedpairs
