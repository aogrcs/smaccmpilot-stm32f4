{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE MultiParamTypeClasses #-}

-- Autogenerated Mavlink v1.0 implementation: see smavgen_ivory.py

module SMACCMPilot.Mavlink.Messages.Data64 where

import Ivory.Language
import Ivory.Serialize
import SMACCMPilot.Mavlink.Send
import SMACCMPilot.Mavlink.Unpack

data64MsgId :: Uint8
data64MsgId = 171

data64CrcExtra :: Uint8
data64CrcExtra = 170

data64Module :: Module
data64Module = package "mavlink_data64_msg" $ do
  depend serializeModule
  depend mavlinkSendModule
  incl mkData64Sender
  incl data64Unpack
  defStruct (Proxy :: Proxy "data64_msg")
  wrappedPackMod data64Wrapper

[ivory|
struct data64_msg
  { data64_type :: Stored Uint8
  ; len :: Stored Uint8
  ; data64 :: Array 64 (Stored Uint8)
  }
|]

mkData64Sender ::
  Def ('[ ConstRef s0 (Struct "data64_msg")
        , Ref s1 (Stored Uint8) -- seqNum
        , Ref s1 (Struct "mavlinkPacket") -- tx buffer/length
        ] :-> ())
mkData64Sender = makeMavlinkSender "data64_msg" data64MsgId data64CrcExtra

instance MavlinkUnpackableMsg "data64_msg" where
    unpackMsg = ( data64Unpack , data64MsgId )

data64Unpack :: Def ('[ Ref s1 (Struct "data64_msg")
                             , ConstRef s2 (CArray (Stored Uint8))
                             ] :-> () )
data64Unpack = proc "mavlink_data64_unpack" $ \ msg buf -> body $ packGet packRep buf 0 msg

data64Wrapper :: WrappedPackRep (Struct "data64_msg")
data64Wrapper = wrapPackRep "mavlink_data64" $ packStruct
  [ packLabel data64_type
  , packLabel len
  , packLabel data64
  ]

instance Packable (Struct "data64_msg") where
  packRep = wrappedPackRep data64Wrapper
