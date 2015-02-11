{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE MultiParamTypeClasses #-}

-- Autogenerated Mavlink v1.0 implementation: see smavgen_ivory.py

module SMACCMPilot.Mavlink.Messages.ParamValue where

import Ivory.Language
import Ivory.Serialize
import SMACCMPilot.Mavlink.Send
import SMACCMPilot.Mavlink.Unpack

paramValueMsgId :: Uint8
paramValueMsgId = 22

paramValueCrcExtra :: Uint8
paramValueCrcExtra = 220

paramValueModule :: Module
paramValueModule = package "mavlink_param_value_msg" $ do
  depend serializeModule
  depend mavlinkSendModule
  incl mkParamValueSender
  incl paramValueUnpack
  defStruct (Proxy :: Proxy "param_value_msg")
  wrappedPackMod paramValueWrapper

[ivory|
struct param_value_msg
  { param_value :: Stored IFloat
  ; param_count :: Stored Uint16
  ; param_index :: Stored Uint16
  ; param_id :: Array 16 (Stored Uint8)
  ; param_type :: Stored Uint8
  }
|]

mkParamValueSender ::
  Def ('[ ConstRef s0 (Struct "param_value_msg")
        , Ref s1 (Stored Uint8) -- seqNum
        , Ref s1 (Struct "mavlinkPacket") -- tx buffer/length
        ] :-> ())
mkParamValueSender = makeMavlinkSender "param_value_msg" paramValueMsgId paramValueCrcExtra

instance MavlinkUnpackableMsg "param_value_msg" where
    unpackMsg = ( paramValueUnpack , paramValueMsgId )

paramValueUnpack :: Def ('[ Ref s1 (Struct "param_value_msg")
                             , ConstRef s2 (CArray (Stored Uint8))
                             ] :-> () )
paramValueUnpack = proc "mavlink_param_value_unpack" $ \ msg buf -> body $ packGet packRep buf 0 msg

paramValueWrapper :: WrappedPackRep (Struct "param_value_msg")
paramValueWrapper = wrapPackRep "mavlink_param_value" $ packStruct
  [ packLabel param_value
  , packLabel param_count
  , packLabel param_index
  , packLabel param_id
  , packLabel param_type
  ]

instance Packable (Struct "param_value_msg") where
  packRep = wrappedPackRep paramValueWrapper
