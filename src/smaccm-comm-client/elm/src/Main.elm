port module Main exposing (..)

--import Basics.Extra exposing (never)
import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes as A exposing (..)
import Http
import Keyboard
import Task
import Time exposing (Time, millisecond, second)

import Bbox exposing (..)
import PFD exposing (..)

import SMACCMPilot.Comm.Interface.ControllableVehicle as CV exposing (ControllableVehicle)
import SMACCMPilot.Comm.Types.ArmingMode as ArmingMode
import SMACCMPilot.Comm.Types.ControlSource as ControlSource
import SMACCMPilot.Comm.Types.PackedStatus as PackedStatus exposing (PackedStatus)
import SMACCMPilot.Comm.Types.RebootMagic as RebootMagic
import SMACCMPilot.Comm.Types.RebootReq as RebootReq
import SMACCMPilot.Comm.Types.ThrottleMode as ThrottleMode
import SMACCMPilot.Comm.Types.Tristate as Tristate
import SMACCMPilot.Comm.Types.YawMode as YawMode

main : Program Never Model Msg
main =
  Html.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }

-- MODEL

type alias Model =
  { cv : ControllableVehicle
  , refreshRate : Float -- milliseconds
  , latencySmoother : Smoother
  , lastUpdate : Time
  , lastUpdateDts : List Float -- milliseconds
  , httpError : Maybe Http.Error
  }

cvc : CV.Client Msg
cvc = CV.client FetchFail CVResponse "http://localhost:8080"

init : (Model, Cmd Msg)
init =
  let altWeights = [
          -0.004079714666025863
        , -0.011002950421607123
        , -0.004853702172814258
        , 0.03994619789045572
        , 0.12899291808975988
        , 0.22464354904548067
        , 0.26647104342536615
        , 0.22464354904548067
        , 0.12899291808975988
        , 0.03994619789045572
        , -0.004853702172814258
        , -0.011002950421607123
        , -0.004079714666025863
        ]
      latencyWeights = [
          0.11538864317459548
        , 0.36510250931275834
        , 0.5000373407321809
        , 0.36510250931275834
        , 0.11538864317459548
        , 0.0006633631777757225
        ]
  in ( { cv = CV.init
       , refreshRate = 200
       , latencySmoother = mkSmoother latencyWeights
       , lastUpdate = 0
       , lastUpdateDts = []
       , httpError = Nothing
       }
     , cvc.getPackedStatus
     )

-- UPDATE

type Msg
  = Poll
  | SetRefreshRate String -- Float hz
  | UpdateLatency Time
  | UpdateTime Time
  | CVResponse CV.Response
  | SendReboot
  | KeyUp Keyboard.KeyCode
  | KeyDown Keyboard.KeyCode
  | FetchTuning
  | FetchFail Http.Error

cvh : CV.Handler Model Msg
cvh = let upd m f = { m | cv = f m.cv } in CV.updatingHandler upd

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Poll ->
      model ! [ cvc.getPackedStatus, cvc.getCameraTargetInput ]
    SetRefreshRate hzStr ->
      case String.toFloat hzStr of
        Ok hz -> { model | refreshRate = 1*second / (hz + 0.0001) } ! []
        Err _ -> model ! []
    UpdateLatency time ->
      let -- use the current dt if we haven't seen a sample since the last update
          dt = Time.inMilliseconds time - Time.inMilliseconds model.lastUpdate
          window = model.latencySmoother.firState.size
          s1 =
            case model.lastUpdateDts of
              [] -> putSome model.latencySmoother (List.repeat window dt)
              ls -> putSome model.latencySmoother ls
          v = s1.value
      in { model | latencySmoother = s1, lastUpdateDts = [] } ! [
          if v > 5000 && model.refreshRate < 10*second then showModal () else hideModal ()
        ]
    UpdateTime time ->
      let dt = Time.inMilliseconds time - Time.inMilliseconds model.lastUpdate
      in { model | lastUpdate = time, lastUpdateDts = dt :: model.lastUpdateDts } ! []
    CVResponse resp ->
      let (model1, cmd) = CV.handle cvh resp model
          model2 = updateSmoothers model1
      in { model2 | httpError = Nothing } ! [ cmd, Task.perform UpdateTime Time.now ]
    SendReboot -> (model, cvc.setRebootReq (RebootReq.RebootReq RebootMagic.LinuxRebootMagic1))
    KeyUp kc -> model ! []
    KeyDown kc -> model ! []
    FetchTuning -> model ! fetchTuning
    FetchFail err ->
      { model | httpError = Just err } ! []

fetchTuning : List (Cmd Msg)
fetchTuning = [
    cvc.getAltitudeRatePid
  , cvc.getAltitudePositionPid
  , cvc.getAttitudeRollStab
  , cvc.getAttitudePitchStab
  , cvc.getYawRatePid
  , cvc.getYawPositionPid
  ]

updateSmoothers : Model -> Model
updateSmoothers model = model

-- VIEW

view : Model -> Html Msg
view model =
  div [ class "container" ] [
    errorModal model
  , div [ class "panel panel-default" ] [ div [ class "panel-heading" ] [ h2 [ class "panel-title" ] [ text "SMACCMPilot" ] ], div [ class "panel-body" ] [
      div [ class "row" ] [
        div [ class "col-xs-5" ] [
          div [ class "panel panel-default" ] [
            ul [ class "nav nav-tabs", attribute "role" "tablist" ] [
                li [ class "active" ] [ a [ href "#pfd", attribute "data-toggle" "tab" ] [ strong [ ] [ text "PFD" ] ] ]
              , li [ ] [ a [ href "#bbox", attribute "data-toggle" "tab" ] [ strong [ ] [ text "Camera Target" ] ] ]
              ]
          , div [ class "panel-body" ] [
              div [ class "tab-content" ] [
                div [ class "tab-pane active", id "pfd" ] [
                    pfd model.cv.packedStatus.pitch
                        model.cv.packedStatus.roll
                        model.cv.packedStatus.alt_est
                        model.cv.packedStatus.yaw
                    ]
              , div [ class "tab-pane", id "bbox" ] [ bbox model.cv.cameraTargetInput ]
              ]
            ]
          ]
        ]
      , div [ class "col-xs-7" ] [
          div [ class "panel panel-default" ] [
            ul [ class "nav nav-tabs", attribute "role" "tablist" ] [
                li [ class "active" ] [ a [ href "#calibration", attribute "data-toggle" "tab" ] [ strong [ ] [ text "Calibration" ] ] ]
              , li [ ] [ a [href "#status", attribute "data-toggle" "tab" ] [ strong [ ] [ text "Control Law Status" ] ] ]
              , li [ ] [ a [href "#tuning", attribute "data-toggle" "tab" , onClick FetchTuning ] [ strong [ ] [ text "Tuning" ] ] ]
              ]
          , div [ class "panel-body" ] [
              div [ class "tab-content" ] [
                div [ class "tab-pane active", id "calibration" ] [ renderCalibration model.cv.packedStatus ]
              , div [ class "tab-pane", id "status" ] [ renderStatus model.cv.packedStatus ]
              , div [ class "tab-pane", id "control" ] [ renderControl model ]
              , div [ class "tab-pane", id "tuning" ] [ renderTuning model ]
              ]
            ]
          ]
        ]
    ]
    , hr [ ] [ ]
    , div [ class "row" ] [
        div [ class "col-xs-12" ] [ table [ class "table" ] [ tbody [ ] [
            tr
              [ let v = model.latencySmoother.value
                in class (if v < 1000
                          then "success"
                          else if v >= 1000 && v < 5000
                          then "warning"
                          else "danger") ]
              [ thLabel 80 "Time between updates", td [ ] [ text (toString (round model.latencySmoother.value) ++ "ms") ] ]
          , tr [ ] [ thLabel 80 "Refresh rate"
                   , td [ ] [ div [ class "input-group" ] [
                                input [ class "form-control"
                                      , name "refresh-rate"
                                      , type_  "number"
                                      , value (toString (round (1000 / model.refreshRate)))
                                      , A.min (toString 0)
                                      , A.max (toString 15)
                                      , onInput SetRefreshRate
                                      ] []
                     , span [ class "input-group-addon" ] [ text "hz" ] ] ] ]
          , tr [ ] [ thLabel 80 "Linux VM"
                   , td [ ] [ node "button"
                                [ class "btn btn-primary btn-lg btn-block", onClick SendReboot ]
                                [ text "Reboot" ] ] ]
         ] ] ] ]
    , div [ class "row" ] [ div [ class "col-xs-12" ] [
          case model.httpError of
            Just err -> div [ class "alert alert-warning" ] [ text (toString err) ]
            Nothing -> div [] []
        ] ]
    ] ] ]

thLabel w str = th [ style [ ("width", toString w ++ "%"), ("vertical-align", "middle") ] ] [ text str ]

renderControl : Model -> Html Msg
renderControl model = div [ ] [ ]

renderTuning : Model -> Html Msg
renderTuning model = div [ ] [
    div [ class "panel panel-default" ] [
        div [ class "panel-heading" ] [ h2 [ class "panel-title" ] [ text "Altitude" ] ]
      , div [ class "panel-body" ] [ text "Altitude stuff" ] ]
  , div [ class "panel panel-default" ] [
        div [ class "panel-heading" ] [ h2 [ class "panel-title" ] [ text "Attitude" ] ]
      , div [ class "panel-body" ] [ text "Attitude stuff" ] ]
  , div [ class "panel panel-default" ] [
        div [ class "panel-heading" ] [ h2 [ class "panel-title" ] [ text "Yaw" ] ]
      , div [ class "panel-body" ] [ text "Yaw stuff" ] ]
  ]

renderCalibration : PackedStatus -> Html Msg
renderCalibration packedStatus =
  let label str = th [ style [ ("width", "10%") ] ] [ text str ]
  in table [ class "table" ] [ tbody [ ] [
         tr [ ] [ label "Gyro", td [ ] [ renderCalProgress packedStatus.gyro_progress ] ]
       , tr [ ] [ label "Mag", td [ ] [ renderCalProgress packedStatus.mag_progress ] ]
       ] ]

renderStatus : PackedStatus -> Html Msg
renderStatus packedStatus =
  let label str = th [ style [ ("width", "20%"), ("vertical-align", "middle") ] ] [ text str ]
      bgrp btns = div [ class "btn-group btn-group-justified btn-group-sm" ] btns
      btn lbl active =
        let cls = if active then "btn-primary" else "btn-default"
        in div [ class "btn-group" ] [ node "button" [ class ("btn " ++ cls), attribute "disabled" "disabled" ] [ text lbl ] ]
      tristate lbl st =
        tr [ ] [ label lbl, td [ ] [ bgrp [
                     btn "Negative" (st == Tristate.Negative)
                   , btn "Neutral" (st == Tristate.Neutral)
                   , btn "Positive" (st == Tristate.Positive)
                   ] ] ]
  in table [ class "table" ] [ tbody [ ] [
         tr [ ] [ label "Arming Mode", td [ ] [ bgrp [
                      btn "Safe" (packedStatus.arming_mode == ArmingMode.Safe)
                    , btn "Armed" (packedStatus.arming_mode == ArmingMode.Armed)
                    ] ] ]
       , tr [ ] [ label "Throttle Mode", td [ ] [ bgrp [
                      btn "DirectUi" (packedStatus.control_modes.thr_mode == ThrottleMode.DirectUi)
                    , btn "AltUi" (packedStatus.control_modes.thr_mode == ThrottleMode.AltUi)
                    , btn "AltSetpt" (packedStatus.control_modes.thr_mode == ThrottleMode.AltSetpt)
                    ] ] ]
       , tr [ ] [ label "UI Mode", td [ ] [ bgrp [
                      btn "Ppm" (packedStatus.control_modes.ui_mode == ControlSource.Ppm)
                    , btn "Gcs" (packedStatus.control_modes.ui_mode == ControlSource.Gcs)
                    , btn "Nav" (packedStatus.control_modes.ui_mode == ControlSource.Nav)
                    ] ] ]
       , tr [ ] [ label "Yaw Mode", td [ ] [ bgrp [
                      btn "Rate" (packedStatus.control_modes.yaw_mode == YawMode.Rate)
                    , btn "Heading" (packedStatus.control_modes.yaw_mode == YawMode.Heading)
                    ] ] ]
       , tristate "rcinput" packedStatus.rcinput
       , tristate "telem" packedStatus.telem
       , tristate "px4io" packedStatus.px4io
       , tristate "sens_cal" packedStatus.sens_cal
       ] ]

renderCalProgress : Float -> Html Msg
renderCalProgress p =
  let inProgress = p < 1.0
      pct = toString (p * 100) ++ "%"
  in div [ class "progress", style [ ("margin-bottom", "0") ] ]
       [ div [ classList [
                   ("progress-bar", True)
                 , ("progress-bar-striped", True)
                 , ("active", inProgress)
                 , ("progress-bar-info", inProgress)
                 , ("progress-bar-success", not inProgress)
                 ]
             , style [ ("width", pct) ]
             ]
           [ text pct ]
       ]

errorModal model =
  div [ class "modal fade"
      , id "errorModal"
      , attribute "tabindex" "-1"
      , attribute "role" "dialog" ] [
    div [ class "modal-dialog modal-lg"
        , attribute "role" "document" ] [
      div [ class "modal-content"
          , style [ ("background-color", "black")
                  , ("color", "red")
                  , ("text-align", "center") ] ] [
        div [ class "modal-body" ] [
          let elapsed = toString (round (model.latencySmoother.value / 1000))
          in h1 [ class "modal-title" ] [ text ("Connection Lost: " ++ elapsed ++ "s") ]
        ]
      ]
    ]
  ]

port showModal : () -> Cmd msg
port hideModal : () -> Cmd msg

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model = Sub.batch [
    Time.every (model.refreshRate * millisecond) (\_ -> Poll)
  , Time.every second UpdateLatency
  ]

-- MOVE TO ANOTHER MODULE

type alias FIR =
  { weights : List Float
  , inputs : List Float
  , size : Int
  }

{-| Initialize a FIR filter with impulse response coefficients listed from most to least recent -}
mkFir : List Float -> FIR
mkFir ws =
  let s = List.length ws
  in { weights = ws, inputs = List.repeat s 0.0, size = s }

{-| Run a FIR filter with a list of inputs from most to least recent. Returns the intermediate outputs and the updated filter state -}
fir : FIR -> List Float -> (List Float, FIR)
fir f is =
  let go i (os, f1) =
        let (o, f2) = fir1 f1 i
        in (o :: os, f2)
  in List.foldr go ([], f) is

{-| Run a FIR filter with a single new input. Returns the output and the updated filter state -}
fir1 : FIR -> Float -> (Float, FIR)
fir1 f i =
  let output = List.foldr go 0 (List.map2 (,) f.weights inputs1)
      inputs1 = List.take f.size (i :: f.inputs)
      f1 = { f | inputs = inputs1 }
      go (w, i) s = s + (w * i)
  in (output, f1)

type alias Smoother =
  { firState : FIR
  , value : Float
  , mag : Float
  }

mkSmoother ws =
  { firState = mkFir ws, mag = List.sum ws, value = 0 }

putNext : Smoother -> Float -> Smoother
putNext s i =
  let (v, fs1) = fir1 s.firState i
  in { s | firState = fs1, value = v / s.mag }

putSome : Smoother -> List Float -> Smoother
putSome s is =
  let (vs, fs1) = fir s.firState is
  in { s | firState = fs1, value = Maybe.withDefault s.value (Maybe.map (\x -> x / s.mag) (List.head vs)) }
