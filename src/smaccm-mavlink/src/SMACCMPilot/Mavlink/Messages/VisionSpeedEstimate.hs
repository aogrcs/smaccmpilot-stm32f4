{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE MultiParamTypeClasses #-}

-- Autogenerated Mavlink v1.0 implementation: see smavgen_ivory.py

module SMACCMPilot.Mavlink.Messages.VisionSpeedEstimate where

import Ivory.Language
import Ivory.Serialize
import SMACCMPilot.Mavlink.Send
import SMACCMPilot.Mavlink.Unpack

visionSpeedEstimateMsgId :: Uint8
visionSpeedEstimateMsgId = 103

visionSpeedEstimateCrcExtra :: Uint8
visionSpeedEstimateCrcExtra = 208

visionSpeedEstimateModule :: Module
visionSpeedEstimateModule = package "mavlink_vision_speed_estimate_msg" $ do
  depend serializeModule
  depend mavlinkSendModule
  incl mkVisionSpeedEstimateSender
  incl visionSpeedEstimateUnpack
  defStruct (Proxy :: Proxy "vision_speed_estimate_msg")
  wrappedPackMod visionSpeedEstimateWrapper

[ivory|
struct vision_speed_estimate_msg
  { usec :: Stored Uint64
  ; x :: Stored IFloat
  ; y :: Stored IFloat
  ; z :: Stored IFloat
  }
|]

mkVisionSpeedEstimateSender ::
  Def ('[ ConstRef s0 (Struct "vision_speed_estimate_msg")
        , Ref s1 (Stored Uint8) -- seqNum
        , Ref s1 (Struct "mavlinkPacket") -- tx buffer/length
        ] :-> ())
mkVisionSpeedEstimateSender = makeMavlinkSender "vision_speed_estimate_msg" visionSpeedEstimateMsgId visionSpeedEstimateCrcExtra

instance MavlinkUnpackableMsg "vision_speed_estimate_msg" where
    unpackMsg = ( visionSpeedEstimateUnpack , visionSpeedEstimateMsgId )

visionSpeedEstimateUnpack :: Def ('[ Ref s1 (Struct "vision_speed_estimate_msg")
                             , ConstRef s2 (CArray (Stored Uint8))
                             ] :-> () )
visionSpeedEstimateUnpack = proc "mavlink_vision_speed_estimate_unpack" $ \ msg buf -> body $ packGet packRep buf 0 msg

visionSpeedEstimateWrapper :: WrappedPackRep (Struct "vision_speed_estimate_msg")
visionSpeedEstimateWrapper = wrapPackRep "mavlink_vision_speed_estimate" $ packStruct
  [ packLabel usec
  , packLabel x
  , packLabel y
  , packLabel z
  ]

instance Packable (Struct "vision_speed_estimate_msg") where
  packRep = wrappedPackRep visionSpeedEstimateWrapper
