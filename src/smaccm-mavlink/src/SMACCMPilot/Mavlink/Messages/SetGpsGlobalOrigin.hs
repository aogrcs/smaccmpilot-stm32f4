{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE MultiParamTypeClasses #-}

-- Autogenerated Mavlink v1.0 implementation: see smavgen_ivory.py

module SMACCMPilot.Mavlink.Messages.SetGpsGlobalOrigin where

import Ivory.Language
import Ivory.Serialize
import SMACCMPilot.Mavlink.Send
import SMACCMPilot.Mavlink.Unpack

setGpsGlobalOriginMsgId :: Uint8
setGpsGlobalOriginMsgId = 48

setGpsGlobalOriginCrcExtra :: Uint8
setGpsGlobalOriginCrcExtra = 41

setGpsGlobalOriginModule :: Module
setGpsGlobalOriginModule = package "mavlink_set_gps_global_origin_msg" $ do
  depend serializeModule
  depend mavlinkSendModule
  incl mkSetGpsGlobalOriginSender
  incl setGpsGlobalOriginUnpack
  defStruct (Proxy :: Proxy "set_gps_global_origin_msg")
  wrappedPackMod setGpsGlobalOriginWrapper

[ivory|
struct set_gps_global_origin_msg
  { latitude :: Stored Sint32
  ; longitude :: Stored Sint32
  ; altitude :: Stored Sint32
  ; target_system :: Stored Uint8
  }
|]

mkSetGpsGlobalOriginSender ::
  Def ('[ ConstRef s0 (Struct "set_gps_global_origin_msg")
        , Ref s1 (Stored Uint8) -- seqNum
        , Ref s1 (Struct "mavlinkPacket") -- tx buffer/length
        ] :-> ())
mkSetGpsGlobalOriginSender = makeMavlinkSender "set_gps_global_origin_msg" setGpsGlobalOriginMsgId setGpsGlobalOriginCrcExtra

instance MavlinkUnpackableMsg "set_gps_global_origin_msg" where
    unpackMsg = ( setGpsGlobalOriginUnpack , setGpsGlobalOriginMsgId )

setGpsGlobalOriginUnpack :: Def ('[ Ref s1 (Struct "set_gps_global_origin_msg")
                             , ConstRef s2 (CArray (Stored Uint8))
                             ] :-> () )
setGpsGlobalOriginUnpack = proc "mavlink_set_gps_global_origin_unpack" $ \ msg buf -> body $ packGet packRep buf 0 msg

setGpsGlobalOriginWrapper :: WrappedPackRep (Struct "set_gps_global_origin_msg")
setGpsGlobalOriginWrapper = wrapPackRep "mavlink_set_gps_global_origin" $ packStruct
  [ packLabel latitude
  , packLabel longitude
  , packLabel altitude
  , packLabel target_system
  ]

instance Packable (Struct "set_gps_global_origin_msg") where
  packRep = wrappedPackRep setGpsGlobalOriginWrapper
