{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE MultiParamTypeClasses #-}

-- Autogenerated Mavlink v1.0 implementation: see smavgen_ivory.py

module SMACCMPilot.Mavlink.Messages.ParamSet where

import SMACCMPilot.Mavlink.Pack
import SMACCMPilot.Mavlink.Unpack
import SMACCMPilot.Mavlink.Send

import Ivory.Language
import Ivory.Stdlib

paramSetMsgId :: Uint8
paramSetMsgId = 23

paramSetCrcExtra :: Uint8
paramSetCrcExtra = 168

paramSetModule :: Module
paramSetModule = package "mavlink_param_set_msg" $ do
  depend packModule
  depend mavlinkSendModule
  incl mkParamSetSender
  incl paramSetUnpack
  defStruct (Proxy :: Proxy "param_set_msg")

[ivory|
struct param_set_msg
  { param_value :: Stored IFloat
  ; target_system :: Stored Uint8
  ; target_component :: Stored Uint8
  ; param_type :: Stored Uint8
  ; param_id :: Array 16 (Stored Uint8)
  }
|]

mkParamSetSender ::
  Def ('[ ConstRef s0 (Struct "param_set_msg")
        , Ref s1 (Stored Uint8) -- seqNum
        , Ref s1 (Struct "mavlinkPacket") -- tx buffer/length
        ] :-> ())
mkParamSetSender =
  proc "mavlink_param_set_msg_send"
  $ \msg seqNum sendStruct -> body
  $ do
  arr <- local (iarray [] :: Init (Array 23 (Stored Uint8)))
  let buf = toCArray arr
  call_ pack buf 0 =<< deref (msg ~> param_value)
  call_ pack buf 4 =<< deref (msg ~> target_system)
  call_ pack buf 5 =<< deref (msg ~> target_component)
  call_ pack buf 22 =<< deref (msg ~> param_type)
  arrayPack buf 6 (msg ~> param_id)
  -- 6: header len, 2: CRC len
  let usedLen    = 6 + 23 + 2 :: Integer
  let sendArr    = sendStruct ~> mav_array
  let sendArrLen = arrayLen sendArr
  if sendArrLen < usedLen
    then error "paramSet payload of length 23 is too large!"
    else do -- Copy, leaving room for the payload
            arrayCopy sendArr arr 6 (arrayLen arr)
            call_ mavlinkSendWithWriter
                    paramSetMsgId
                    paramSetCrcExtra
                    23
                    seqNum
                    sendStruct

instance MavlinkUnpackableMsg "param_set_msg" where
    unpackMsg = ( paramSetUnpack , paramSetMsgId )

paramSetUnpack :: Def ('[ Ref s1 (Struct "param_set_msg")
                             , ConstRef s2 (CArray (Stored Uint8))
                             ] :-> () )
paramSetUnpack = proc "mavlink_param_set_unpack" $ \ msg buf -> body $ do
  store (msg ~> param_value) =<< call unpack buf 0
  store (msg ~> target_system) =<< call unpack buf 4
  store (msg ~> target_component) =<< call unpack buf 5
  store (msg ~> param_type) =<< call unpack buf 22
  arrayUnpack buf 6 (msg ~> param_id)

