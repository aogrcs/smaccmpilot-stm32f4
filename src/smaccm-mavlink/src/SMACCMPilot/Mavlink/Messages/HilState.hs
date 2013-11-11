{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE MultiParamTypeClasses #-}

-- Autogenerated Mavlink v1.0 implementation: see smavgen_ivory.py

module SMACCMPilot.Mavlink.Messages.HilState where

import SMACCMPilot.Mavlink.Pack
import SMACCMPilot.Mavlink.Unpack
import SMACCMPilot.Mavlink.Send

import Ivory.Language
import Ivory.Stdlib

hilStateMsgId :: Uint8
hilStateMsgId = 90

hilStateCrcExtra :: Uint8
hilStateCrcExtra = 183

hilStateModule :: Module
hilStateModule = package "mavlink_hil_state_msg" $ do
  depend packModule
  depend mavlinkSendModule
  incl mkHilStateSender
  incl hilStateUnpack
  defStruct (Proxy :: Proxy "hil_state_msg")

[ivory|
struct hil_state_msg
  { time_usec :: Stored Uint64
  ; roll :: Stored IFloat
  ; pitch :: Stored IFloat
  ; yaw :: Stored IFloat
  ; rollspeed :: Stored IFloat
  ; pitchspeed :: Stored IFloat
  ; yawspeed :: Stored IFloat
  ; lat :: Stored Sint32
  ; lon :: Stored Sint32
  ; alt :: Stored Sint32
  ; vx :: Stored Sint16
  ; vy :: Stored Sint16
  ; vz :: Stored Sint16
  ; xacc :: Stored Sint16
  ; yacc :: Stored Sint16
  ; zacc :: Stored Sint16
  }
|]

mkHilStateSender ::
  Def ('[ ConstRef s0 (Struct "hil_state_msg")
        , Ref s1 (Stored Uint8) -- seqNum
        , Ref s1 (Struct "mavlinkPacket") -- tx buffer/length
        ] :-> ())
mkHilStateSender =
  proc "mavlink_hil_state_msg_send"
  $ \msg seqNum sendStruct -> body
  $ do
  arr <- local (iarray [] :: Init (Array 56 (Stored Uint8)))
  let buf = toCArray arr
  call_ pack buf 0 =<< deref (msg ~> time_usec)
  call_ pack buf 8 =<< deref (msg ~> roll)
  call_ pack buf 12 =<< deref (msg ~> pitch)
  call_ pack buf 16 =<< deref (msg ~> yaw)
  call_ pack buf 20 =<< deref (msg ~> rollspeed)
  call_ pack buf 24 =<< deref (msg ~> pitchspeed)
  call_ pack buf 28 =<< deref (msg ~> yawspeed)
  call_ pack buf 32 =<< deref (msg ~> lat)
  call_ pack buf 36 =<< deref (msg ~> lon)
  call_ pack buf 40 =<< deref (msg ~> alt)
  call_ pack buf 44 =<< deref (msg ~> vx)
  call_ pack buf 46 =<< deref (msg ~> vy)
  call_ pack buf 48 =<< deref (msg ~> vz)
  call_ pack buf 50 =<< deref (msg ~> xacc)
  call_ pack buf 52 =<< deref (msg ~> yacc)
  call_ pack buf 54 =<< deref (msg ~> zacc)
  -- 6: header len, 2: CRC len
  let usedLen    = 6 + 56 + 2 :: Integer
  let sendArr    = sendStruct ~> mav_array
  let sendArrLen = arrayLen sendArr
  if sendArrLen < usedLen
    then error "hilState payload of length 56 is too large!"
    else do -- Copy, leaving room for the payload
            arrayCopy sendArr arr 6 (arrayLen arr)
            call_ mavlinkSendWithWriter
                    hilStateMsgId
                    hilStateCrcExtra
                    56
                    seqNum
                    sendStruct

instance MavlinkUnpackableMsg "hil_state_msg" where
    unpackMsg = ( hilStateUnpack , hilStateMsgId )

hilStateUnpack :: Def ('[ Ref s1 (Struct "hil_state_msg")
                             , ConstRef s2 (CArray (Stored Uint8))
                             ] :-> () )
hilStateUnpack = proc "mavlink_hil_state_unpack" $ \ msg buf -> body $ do
  store (msg ~> time_usec) =<< call unpack buf 0
  store (msg ~> roll) =<< call unpack buf 8
  store (msg ~> pitch) =<< call unpack buf 12
  store (msg ~> yaw) =<< call unpack buf 16
  store (msg ~> rollspeed) =<< call unpack buf 20
  store (msg ~> pitchspeed) =<< call unpack buf 24
  store (msg ~> yawspeed) =<< call unpack buf 28
  store (msg ~> lat) =<< call unpack buf 32
  store (msg ~> lon) =<< call unpack buf 36
  store (msg ~> alt) =<< call unpack buf 40
  store (msg ~> vx) =<< call unpack buf 44
  store (msg ~> vy) =<< call unpack buf 46
  store (msg ~> vz) =<< call unpack buf 48
  store (msg ~> xacc) =<< call unpack buf 50
  store (msg ~> yacc) =<< call unpack buf 52
  store (msg ~> zacc) =<< call unpack buf 54

