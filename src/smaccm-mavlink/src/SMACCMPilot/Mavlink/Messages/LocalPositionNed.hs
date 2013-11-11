{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE MultiParamTypeClasses #-}

-- Autogenerated Mavlink v1.0 implementation: see smavgen_ivory.py

module SMACCMPilot.Mavlink.Messages.LocalPositionNed where

import SMACCMPilot.Mavlink.Pack
import SMACCMPilot.Mavlink.Unpack
import SMACCMPilot.Mavlink.Send

import Ivory.Language
import Ivory.Stdlib

localPositionNedMsgId :: Uint8
localPositionNedMsgId = 32

localPositionNedCrcExtra :: Uint8
localPositionNedCrcExtra = 185

localPositionNedModule :: Module
localPositionNedModule = package "mavlink_local_position_ned_msg" $ do
  depend packModule
  depend mavlinkSendModule
  incl mkLocalPositionNedSender
  incl localPositionNedUnpack
  defStruct (Proxy :: Proxy "local_position_ned_msg")

[ivory|
struct local_position_ned_msg
  { time_boot_ms :: Stored Uint32
  ; x :: Stored IFloat
  ; y :: Stored IFloat
  ; z :: Stored IFloat
  ; vx :: Stored IFloat
  ; vy :: Stored IFloat
  ; vz :: Stored IFloat
  }
|]

mkLocalPositionNedSender ::
  Def ('[ ConstRef s0 (Struct "local_position_ned_msg")
        , Ref s1 (Stored Uint8) -- seqNum
        , Ref s1 (Struct "mavlinkPacket") -- tx buffer/length
        ] :-> ())
mkLocalPositionNedSender =
  proc "mavlink_local_position_ned_msg_send"
  $ \msg seqNum sendStruct -> body
  $ do
  arr <- local (iarray [] :: Init (Array 28 (Stored Uint8)))
  let buf = toCArray arr
  call_ pack buf 0 =<< deref (msg ~> time_boot_ms)
  call_ pack buf 4 =<< deref (msg ~> x)
  call_ pack buf 8 =<< deref (msg ~> y)
  call_ pack buf 12 =<< deref (msg ~> z)
  call_ pack buf 16 =<< deref (msg ~> vx)
  call_ pack buf 20 =<< deref (msg ~> vy)
  call_ pack buf 24 =<< deref (msg ~> vz)
  -- 6: header len, 2: CRC len
  let usedLen    = 6 + 28 + 2 :: Integer
  let sendArr    = sendStruct ~> mav_array
  let sendArrLen = arrayLen sendArr
  if sendArrLen < usedLen
    then error "localPositionNed payload of length 28 is too large!"
    else do -- Copy, leaving room for the payload
            arrayCopy sendArr arr 6 (arrayLen arr)
            call_ mavlinkSendWithWriter
                    localPositionNedMsgId
                    localPositionNedCrcExtra
                    28
                    seqNum
                    sendStruct

instance MavlinkUnpackableMsg "local_position_ned_msg" where
    unpackMsg = ( localPositionNedUnpack , localPositionNedMsgId )

localPositionNedUnpack :: Def ('[ Ref s1 (Struct "local_position_ned_msg")
                             , ConstRef s2 (CArray (Stored Uint8))
                             ] :-> () )
localPositionNedUnpack = proc "mavlink_local_position_ned_unpack" $ \ msg buf -> body $ do
  store (msg ~> time_boot_ms) =<< call unpack buf 0
  store (msg ~> x) =<< call unpack buf 4
  store (msg ~> y) =<< call unpack buf 8
  store (msg ~> z) =<< call unpack buf 12
  store (msg ~> vx) =<< call unpack buf 16
  store (msg ~> vy) =<< call unpack buf 20
  store (msg ~> vz) =<< call unpack buf 24

