{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE MultiParamTypeClasses #-}

-- Autogenerated Mavlink v1.0 implementation: see smavgen_ivory.py

module SMACCMPilot.Mavlink.Messages.RcChannelsOverride where

import Ivory.Language
import Ivory.Serialize
import SMACCMPilot.Mavlink.Send
import SMACCMPilot.Mavlink.Unpack

rcChannelsOverrideMsgId :: Uint8
rcChannelsOverrideMsgId = 70

rcChannelsOverrideCrcExtra :: Uint8
rcChannelsOverrideCrcExtra = 124

rcChannelsOverrideModule :: Module
rcChannelsOverrideModule = package "mavlink_rc_channels_override_msg" $ do
  depend serializeModule
  depend mavlinkSendModule
  incl mkRcChannelsOverrideSender
  incl rcChannelsOverrideUnpack
  defStruct (Proxy :: Proxy "rc_channels_override_msg")
  wrappedPackMod rcChannelsOverrideWrapper

[ivory|
struct rc_channels_override_msg
  { chan1_raw :: Stored Uint16
  ; chan2_raw :: Stored Uint16
  ; chan3_raw :: Stored Uint16
  ; chan4_raw :: Stored Uint16
  ; chan5_raw :: Stored Uint16
  ; chan6_raw :: Stored Uint16
  ; chan7_raw :: Stored Uint16
  ; chan8_raw :: Stored Uint16
  ; target_system :: Stored Uint8
  ; target_component :: Stored Uint8
  }
|]

mkRcChannelsOverrideSender ::
  Def ('[ ConstRef s0 (Struct "rc_channels_override_msg")
        , Ref s1 (Stored Uint8) -- seqNum
        , Ref s1 (Struct "mavlinkPacket") -- tx buffer/length
        ] :-> ())
mkRcChannelsOverrideSender = makeMavlinkSender "rc_channels_override_msg" rcChannelsOverrideMsgId rcChannelsOverrideCrcExtra

instance MavlinkUnpackableMsg "rc_channels_override_msg" where
    unpackMsg = ( rcChannelsOverrideUnpack , rcChannelsOverrideMsgId )

rcChannelsOverrideUnpack :: Def ('[ Ref s1 (Struct "rc_channels_override_msg")
                             , ConstRef s2 (CArray (Stored Uint8))
                             ] :-> () )
rcChannelsOverrideUnpack = proc "mavlink_rc_channels_override_unpack" $ \ msg buf -> body $ packGet packRep buf 0 msg

rcChannelsOverrideWrapper :: WrappedPackRep (Struct "rc_channels_override_msg")
rcChannelsOverrideWrapper = wrapPackRep "mavlink_rc_channels_override" $ packStruct
  [ packLabel chan1_raw
  , packLabel chan2_raw
  , packLabel chan3_raw
  , packLabel chan4_raw
  , packLabel chan5_raw
  , packLabel chan6_raw
  , packLabel chan7_raw
  , packLabel chan8_raw
  , packLabel target_system
  , packLabel target_component
  ]

instance Packable (Struct "rc_channels_override_msg") where
  packRep = wrappedPackRep rcChannelsOverrideWrapper
