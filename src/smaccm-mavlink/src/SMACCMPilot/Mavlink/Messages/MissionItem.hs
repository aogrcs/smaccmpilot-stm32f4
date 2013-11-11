{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE MultiParamTypeClasses #-}

-- Autogenerated Mavlink v1.0 implementation: see smavgen_ivory.py

module SMACCMPilot.Mavlink.Messages.MissionItem where

import SMACCMPilot.Mavlink.Pack
import SMACCMPilot.Mavlink.Unpack
import SMACCMPilot.Mavlink.Send

import Ivory.Language
import Ivory.Stdlib

missionItemMsgId :: Uint8
missionItemMsgId = 39

missionItemCrcExtra :: Uint8
missionItemCrcExtra = 254

missionItemModule :: Module
missionItemModule = package "mavlink_mission_item_msg" $ do
  depend packModule
  depend mavlinkSendModule
  incl mkMissionItemSender
  incl missionItemUnpack
  defStruct (Proxy :: Proxy "mission_item_msg")

[ivory|
struct mission_item_msg
  { param1 :: Stored IFloat
  ; param2 :: Stored IFloat
  ; param3 :: Stored IFloat
  ; param4 :: Stored IFloat
  ; x :: Stored IFloat
  ; y :: Stored IFloat
  ; z :: Stored IFloat
  ; mission_item_seq :: Stored Uint16
  ; command :: Stored Uint16
  ; target_system :: Stored Uint8
  ; target_component :: Stored Uint8
  ; frame :: Stored Uint8
  ; current :: Stored Uint8
  ; autocontinue :: Stored Uint8
  }
|]

mkMissionItemSender ::
  Def ('[ ConstRef s0 (Struct "mission_item_msg")
        , Ref s1 (Stored Uint8) -- seqNum
        , Ref s1 (Struct "mavlinkPacket") -- tx buffer/length
        ] :-> ())
mkMissionItemSender =
  proc "mavlink_mission_item_msg_send"
  $ \msg seqNum sendStruct -> body
  $ do
  arr <- local (iarray [] :: Init (Array 37 (Stored Uint8)))
  let buf = toCArray arr
  call_ pack buf 0 =<< deref (msg ~> param1)
  call_ pack buf 4 =<< deref (msg ~> param2)
  call_ pack buf 8 =<< deref (msg ~> param3)
  call_ pack buf 12 =<< deref (msg ~> param4)
  call_ pack buf 16 =<< deref (msg ~> x)
  call_ pack buf 20 =<< deref (msg ~> y)
  call_ pack buf 24 =<< deref (msg ~> z)
  call_ pack buf 28 =<< deref (msg ~> mission_item_seq)
  call_ pack buf 30 =<< deref (msg ~> command)
  call_ pack buf 32 =<< deref (msg ~> target_system)
  call_ pack buf 33 =<< deref (msg ~> target_component)
  call_ pack buf 34 =<< deref (msg ~> frame)
  call_ pack buf 35 =<< deref (msg ~> current)
  call_ pack buf 36 =<< deref (msg ~> autocontinue)
  -- 6: header len, 2: CRC len
  let usedLen    = 6 + 37 + 2 :: Integer
  let sendArr    = sendStruct ~> mav_array
  let sendArrLen = arrayLen sendArr
  if sendArrLen < usedLen
    then error "missionItem payload of length 37 is too large!"
    else do -- Copy, leaving room for the payload
            arrayCopy sendArr arr 6 (arrayLen arr)
            call_ mavlinkSendWithWriter
                    missionItemMsgId
                    missionItemCrcExtra
                    37
                    seqNum
                    sendStruct

instance MavlinkUnpackableMsg "mission_item_msg" where
    unpackMsg = ( missionItemUnpack , missionItemMsgId )

missionItemUnpack :: Def ('[ Ref s1 (Struct "mission_item_msg")
                             , ConstRef s2 (CArray (Stored Uint8))
                             ] :-> () )
missionItemUnpack = proc "mavlink_mission_item_unpack" $ \ msg buf -> body $ do
  store (msg ~> param1) =<< call unpack buf 0
  store (msg ~> param2) =<< call unpack buf 4
  store (msg ~> param3) =<< call unpack buf 8
  store (msg ~> param4) =<< call unpack buf 12
  store (msg ~> x) =<< call unpack buf 16
  store (msg ~> y) =<< call unpack buf 20
  store (msg ~> z) =<< call unpack buf 24
  store (msg ~> mission_item_seq) =<< call unpack buf 28
  store (msg ~> command) =<< call unpack buf 30
  store (msg ~> target_system) =<< call unpack buf 32
  store (msg ~> target_component) =<< call unpack buf 33
  store (msg ~> frame) =<< call unpack buf 34
  store (msg ~> current) =<< call unpack buf 35
  store (msg ~> autocontinue) =<< call unpack buf 36

