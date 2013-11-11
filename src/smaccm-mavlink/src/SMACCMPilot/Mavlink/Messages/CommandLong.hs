{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE MultiParamTypeClasses #-}

-- Autogenerated Mavlink v1.0 implementation: see smavgen_ivory.py

module SMACCMPilot.Mavlink.Messages.CommandLong where

import SMACCMPilot.Mavlink.Pack
import SMACCMPilot.Mavlink.Unpack
import SMACCMPilot.Mavlink.Send

import Ivory.Language
import Ivory.Stdlib

commandLongMsgId :: Uint8
commandLongMsgId = 76

commandLongCrcExtra :: Uint8
commandLongCrcExtra = 152

commandLongModule :: Module
commandLongModule = package "mavlink_command_long_msg" $ do
  depend packModule
  depend mavlinkSendModule
  incl mkCommandLongSender
  incl commandLongUnpack
  defStruct (Proxy :: Proxy "command_long_msg")

[ivory|
struct command_long_msg
  { param1 :: Stored IFloat
  ; param2 :: Stored IFloat
  ; param3 :: Stored IFloat
  ; param4 :: Stored IFloat
  ; param5 :: Stored IFloat
  ; param6 :: Stored IFloat
  ; param7 :: Stored IFloat
  ; command :: Stored Uint16
  ; target_system :: Stored Uint8
  ; target_component :: Stored Uint8
  ; confirmation :: Stored Uint8
  }
|]

mkCommandLongSender ::
  Def ('[ ConstRef s0 (Struct "command_long_msg")
        , Ref s1 (Stored Uint8) -- seqNum
        , Ref s1 (Struct "mavlinkPacket") -- tx buffer/length
        ] :-> ())
mkCommandLongSender =
  proc "mavlink_command_long_msg_send"
  $ \msg seqNum sendStruct -> body
  $ do
  arr <- local (iarray [] :: Init (Array 33 (Stored Uint8)))
  let buf = toCArray arr
  call_ pack buf 0 =<< deref (msg ~> param1)
  call_ pack buf 4 =<< deref (msg ~> param2)
  call_ pack buf 8 =<< deref (msg ~> param3)
  call_ pack buf 12 =<< deref (msg ~> param4)
  call_ pack buf 16 =<< deref (msg ~> param5)
  call_ pack buf 20 =<< deref (msg ~> param6)
  call_ pack buf 24 =<< deref (msg ~> param7)
  call_ pack buf 28 =<< deref (msg ~> command)
  call_ pack buf 30 =<< deref (msg ~> target_system)
  call_ pack buf 31 =<< deref (msg ~> target_component)
  call_ pack buf 32 =<< deref (msg ~> confirmation)
  -- 6: header len, 2: CRC len
  let usedLen    = 6 + 33 + 2 :: Integer
  let sendArr    = sendStruct ~> mav_array
  let sendArrLen = arrayLen sendArr
  if sendArrLen < usedLen
    then error "commandLong payload of length 33 is too large!"
    else do -- Copy, leaving room for the payload
            arrayCopy sendArr arr 6 (arrayLen arr)
            call_ mavlinkSendWithWriter
                    commandLongMsgId
                    commandLongCrcExtra
                    33
                    seqNum
                    sendStruct

instance MavlinkUnpackableMsg "command_long_msg" where
    unpackMsg = ( commandLongUnpack , commandLongMsgId )

commandLongUnpack :: Def ('[ Ref s1 (Struct "command_long_msg")
                             , ConstRef s2 (CArray (Stored Uint8))
                             ] :-> () )
commandLongUnpack = proc "mavlink_command_long_unpack" $ \ msg buf -> body $ do
  store (msg ~> param1) =<< call unpack buf 0
  store (msg ~> param2) =<< call unpack buf 4
  store (msg ~> param3) =<< call unpack buf 8
  store (msg ~> param4) =<< call unpack buf 12
  store (msg ~> param5) =<< call unpack buf 16
  store (msg ~> param6) =<< call unpack buf 20
  store (msg ~> param7) =<< call unpack buf 24
  store (msg ~> command) =<< call unpack buf 28
  store (msg ~> target_system) =<< call unpack buf 30
  store (msg ~> target_component) =<< call unpack buf 31
  store (msg ~> confirmation) =<< call unpack buf 32

