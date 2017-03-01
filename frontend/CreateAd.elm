module CreateAd exposing (..)

import Html as H
import Html.Attributes as A
import Html.Events as E
import Http
import Json.Decode as Json
import Json.Encode as JS
import State.CreateAd exposing (..)

type Msg
  = NoOp
  | ChangeHeading String
  | ChangeContent String
  | Send
  | SendResponse (Result Http.Error String)


sendAd : Model -> Cmd Msg
sendAd model =
  let
    encoded =
      JS.object
        [ ("heading", JS.string model.heading)
        , ("content", JS.string model.content)
        ]
  in
    Http.post "/api/ad" (Http.jsonBody encoded) Json.string
      |> Http.send SendResponse

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    ChangeHeading str ->
      { model | heading = str } ! []
    ChangeContent str ->
      { model | content = str } ! []
    Send ->
      { model | sending = Sending } ! [ sendAd model ]
    SendResponse (Err _) ->
      { model | sending = FinishedFail } ! []
    SendResponse (Ok id) ->
      { model | sending = FinishedSuccess id } ! []
    NoOp ->
      model ! []

view : Model -> H.Html Msg
view model =
  case model.sending of
    NotSending ->
      H.div
        [ A.class "container"]
        [ H.div
          [ A.class "row create-ad" ]
          [ H.div
            [ A.class "col-xs-12 col-sm-7 create-ad__inputs" ]
            [ H.h2
                [ A.class "create-ad__heading-input" ]
                [ H.input
                  [ A.placeholder "Otsikko"
                  , E.onInput ChangeHeading
                  , A.value model.heading
                  ]
                  []
                ]
            , H.textarea
              [ A.placeholder "Kirjoita ytimekäs ilmoitus"
              , A.class "create-ad__textcontent"
              , E.onInput ChangeContent
              , A.value model.content
              ]
              []
            ]
          , H.div
            [ A.class "col-xs-12 col-sm-5" ]
            [ H.h3
                [ A.class "create-ad__filters-heading"]
                [ H.text "Kenen toivot vastaavan?" ]
            , H.p [] [ H.text "Vastaajatarjokkaiden haku on tulossa pian" ]
            , H.p
              [ A.class "create-ad__submit-button" ]
              [ H.button
                  [ A.class "btn btn-primary"
                  , E.onClick Send
                  ]
                  [ H.text "Julkaise ilmoitus"]
              ]
            ]
          ]
        ]

    Sending ->
      H.div [ A.class "splash-screen" ] [ H.text "Lähetetään" ]

    FinishedSuccess id ->
      H.div [ A.class "splash-screen" ] [ H.text <| "Lähetys onnistui: " ++ id ]

    FinishedFail ->
      H.div [ A.class "splash-screen" ] [ H.text "Jotain meni pieleen" ]
