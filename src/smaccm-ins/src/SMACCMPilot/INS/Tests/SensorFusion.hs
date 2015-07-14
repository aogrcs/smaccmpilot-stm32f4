{-# LANGUAGE DataKinds #-}
{-# LANGUAGE RecursiveDo #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE FlexibleContexts #-}

module SMACCMPilot.INS.Tests.SensorFusion
  ( app
  ) where

import Ivory.Language
import Ivory.Serialize
import Ivory.Tower
import SMACCMPilot.Hardware.SensorManager
import SMACCMPilot.Hardware.Tests.Platforms
import SMACCMPilot.Hardware.Tests.Serialize
import SMACCMPilot.Comm.Ivory.Types (typeModules)
import SMACCMPilot.INS.Bias.Calibration
import SMACCMPilot.INS.Bias.Gyro
import SMACCMPilot.INS.Bias.Magnetometer
import SMACCMPilot.INS.Tower

app :: (e -> PX4Platform) -> Tower e ()
app topx4 = do
  (accel_s, gyro_s, mag_s, _baro_s) <- sensorManager tosens tocc

  (_, controlLaw) <- channel

  currentGyroBias <- calcGyroBiasTower gyro_s accel_s
  (gyro_cal, _gyroBias) <- applyCalibrationTower gyroCalibrate gyro_s currentGyroBias controlLaw

  currentMagBias <- calcMagBiasTower mag_s
  (mag_cal, _magBias) <- applyCalibrationTower magCalibrate mag_s currentMagBias controlLaw

  states <- sensorFusion accel_s gyro_cal mag_cal currentGyroBias

  (uartout, _uarti) <- px4ConsoleTower topx4

  p <- period (Milliseconds 40) -- can't send states much faster than 25Hz at 115200bps

  buffered_state <- channel
  monitor "sensorsender" $ do
    last_state <- state "last_state"
    handler states "buffer_state" $ callback $ refCopy last_state

    handler p "deliver_state" $ do
      e <- emitter (fst buffered_state) 1
      callback $ const $ emit e $ constRef last_state

    sampleSender 'f' (Proxy :: Proxy 88) (snd buffered_state) uartout

  towerDepends serializeModule
  towerModule  serializeModule
  mapM_ towerDepends typeModules
  mapM_ towerModule typeModules
  mapM_ towerArtifact serializeArtifacts
  where
  tosens = px4platform_sensors . topx4
  tocc   = px4platform_clockconfig . topx4
