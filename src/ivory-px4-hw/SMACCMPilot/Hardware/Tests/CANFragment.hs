{-# LANGUAGE DataKinds #-}

module SMACCMPilot.Hardware.Tests.CANFragment
  ( app
  ) where

import Ivory.BSP.STM32.Driver.CAN
import Ivory.BSP.STM32.Peripheral.CAN.Filter
import Ivory.Language
import Ivory.Stdlib
import Ivory.Tower
import Ivory.Tower.HAL.Bus.CAN.Fragment
import SMACCMPilot.Comm.Ivory.Types.AccelerometerSample
import SMACCMPilot.Comm.Ivory.Types.BarometerSample
import SMACCMPilot.Comm.Ivory.Types.GyroscopeSample
import SMACCMPilot.Comm.Ivory.Types.MagnetometerSample
import SMACCMPilot.Hardware.CANMessages
import SMACCMPilot.Hardware.GPS.Types
import SMACCMPilot.Hardware.Tests.Platforms
import SMACCMPilot.Hardware.Tests.Serialize
import SMACCMPilot.Mavlink.Ivory.CRC (mavlinkCRCModule)
import SMACCMPilot.Mavlink.Ivory.Messages.SmaccmpilotNavCmd (smaccmpilotNavCmdModule)
import qualified SMACCMPilot.Mavlink.Ivory.Receive as R
import SMACCMPilot.Mavlink.Ivory.Send (mavlinkSendModule)
import SMACCMPilot.Mavlink.Ivory.Unpack

navCmdType :: MessageType (Struct "smaccmpilot_nav_cmd_msg")
navCmdType = messageType 0x701 False (Proxy :: Proxy 32)

app :: (e -> PX4Platform)
    -> Tower e ()
app topx4 = do
  mapM_ (\ m -> towerModule m >> towerDepends m)
    [ mavlinkSendModule
    , mavlinkCRCModule
    , R.mavlinkReceiveStateModule
    , smaccmpilotNavCmdModule
    , accelerometerTypesModule
    , barometerTypesModule
    , gpsTypesModule
    , gyroscopeTypesModule
    , magnetometerTypesModule
    ]
  serializeTowerDeps

  px4platform <- fmap topx4 getEnv
  let tocc = px4platform_clockconfig . topx4

  can <- maybe (fail "fragmentation test requires a CAN peripheral") return $ px4platform_can px4platform
  (canRx, canReq, _, _) <- canTower tocc (can_periph can) 500000 (can_RX can) (can_TX can)

  monitor "can_init" $ handler systemInit "can_init" $ do
    callback $ const $ do
      let emptyID = CANFilterID32 (fromRep 0) (fromRep 0) False False
      canFilterInit (can_filters can) [CANFilterBank CANFIFO0 CANFilterMask $ CANFilter32 emptyID emptyID] []

  (fragSink, fragSource) <- channel
  fragmentSenderBlind fragSource navCmdType canReq

  (ostream, istream) <- px4ConsoleTower topx4

  monitor "decode" $ do
    coroutineHandler systemInit istream "decode_uart" $ do
      toFrag <- emitter fragSink 1
      return $ R.mavlinkReceiver (return ()) $ \ mavState -> do
        let (unpacker, msgid) = unpackMsg
        rxid <- deref (mavState ~> R.msgid)
        when (rxid ==? msgid) $ do
          msg <- local izero
          call_ unpacker msg $ toCArray $ mavState ~> R.payload
          emit toFrag $ constRef msg

  (gyroSrc, gyro_meas) <- channel
  (accelSrc, accel_meas) <- channel
  (magSrc, mag_meas) <- channel
  (baroSrc, baro_meas) <- channel
  (gpsSrc, gps_meas) <- channel

  div_accel_meas <- rateDivider 4 accel_meas
  div_gyro_meas <- rateDivider 4 gyro_meas

  uartTasks <- sequence
    [ do
        (t, req) <- task name
        monitor name $ f req
        return t
    | (name, f) <-
      [ ("mag", magSender mag_meas)
      , ("baro", baroSender baro_meas)
      , ("gyro", gyroSender div_gyro_meas)
      , ("accel", accelSender div_accel_meas)
      , ("gps", positionSender gps_meas)
      ]
    ]
  schedule uartTasks systemInit ostream

  fragmentReceiver canRx
    [ fragmentReceiveHandler gyroSrc gyroType
    , fragmentReceiveHandler accelSrc accelType
    , fragmentReceiveHandler magSrc magType
    , fragmentReceiveHandler baroSrc baroType
    , fragmentReceiveHandler gpsSrc gpsType
    ]
