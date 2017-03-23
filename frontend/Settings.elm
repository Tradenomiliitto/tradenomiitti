module Settings exposing (..)

import Html as H
import Html.Attributes as A
import Html.Events as E
import Http
import Models.User exposing (Settings)
import State.Settings exposing (..)
import Util

type Msg
  = GetSettings (Result Http.Error Settings)
  | UpdateSettings (Result Http.Error ())
  | ToggleEmailsForAnswers Settings
  | Save Settings

getSettings : Cmd Msg
getSettings =
  Http.get "/api/asetukset" Models.User.settingsDecoder
    |> Http.send GetSettings

updateSettings : Settings -> Cmd Msg
updateSettings settings =
  Util.put "/api/asetukset" (Models.User.settingsEncode settings)
    |> Http.send UpdateSettings

initTasks : Cmd Msg
initTasks = getSettings

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    GetSettings (Ok settings) ->
      { model | settings = Just settings } ! []

    GetSettings (Err _) ->
      model ! [] -- TODO error handling

    UpdateSettings (Ok _) ->
      model ! []

    UpdateSettings (Err _) ->
      model ! [] -- TODO error handling

    ToggleEmailsForAnswers settings ->
      { model
        | settings = Just
          { settings
            | emails_for_answers = not settings.emails_for_answers }} ! []

    Save settings ->
      model ! [ updateSettings settings ]



view : Model -> H.Html Msg
view model =
  model.settings
    |> Maybe.map viewSettings
    |> Maybe.withDefault (H.div [] [])

viewSettings : Settings -> H.Html Msg
viewSettings settings =
  H.div
    []
    [ H.label
        []
        [ H.input
          [ A.type_ "checkbox"
          , E.onClick <| ToggleEmailsForAnswers settings
          , A.checked settings.emails_for_answers
          ]
          []
        , H.text "Lähetä ilmoitus sähköpostiin saapuneista vastauksista"
        ]
    , H.button
      [ E.onClick (Save settings)
      ]
      [ H.text "Tallenna" ]
    ]
