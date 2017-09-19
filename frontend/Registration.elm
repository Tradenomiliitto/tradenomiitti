module Registration exposing (..)

import Html as H
import Html.Attributes as A
import Html.Events exposing (onClick, onInput, onWithOptions)
import Http
import Json.Decode
import Json.Decode.Pipeline exposing (decode, required)
import Json.Encode
import State.Registration exposing (..)
import Translation exposing (T)
import Util exposing (UpdateMessage(..))


type Msg
    = Email String
    | Submitted
    | SendResponse (Result Http.Error Response)
    | ToggleConsent


type alias Response =
    { status : String }


submit : Model -> Cmd Msg
submit model =
    let
        encoded =
            Json.Encode.object <|
                [ ( "email", Json.Encode.string model.email )
                ]
    in
    Http.post "/rekisteroidy" (Http.jsonBody encoded) decodeResponse
        |> Http.send SendResponse


decodeResponse : Json.Decode.Decoder Response
decodeResponse =
    decode Response
        |> required "status" Json.Decode.string


update : Msg -> Model -> ( Model, Cmd (UpdateMessage Msg) )
update msg model =
    case msg of
        Email email ->
            { model | email = email } ! []

        SendResponse (Err httpError) ->
            let
                error =
                    case httpError of
                        Http.BadStatus _ ->
                            Failure

                        _ ->
                            NetworkError
            in
            { model | status = error } ! []

        SendResponse (Ok response) ->
            { model | status = Success } ! []

        Submitted ->
            model ! [ Cmd.map LocalUpdateMessage <| submit model ]

        ToggleConsent ->
            { model | consent = not model.consent } ! []


registrationForm : T -> Model -> Maybe String -> H.Html Msg
registrationForm t model errorMessage =
    H.div
        [ A.class "container last-row" ]
        [ H.div
            [ A.class "row registration col-sm-6 col-sm-offset-3" ]
            [ H.form
                [ A.class "registration__container"
                , onWithOptions "submit"
                    { preventDefault = True, stopPropagation = False }
                    (Json.Decode.succeed Submitted)
                ]
                [ H.h1
                    [ A.class "registration__heading" ]
                    [ H.text <| t "registration.title" ]
                , H.p []
                    [ H.text <| t "registration.text"
                    , H.a
                        [ A.href <| t "registration.joinUrl"
                        , A.class "registration__link"
                        ]
                        [ H.text <| t "registration.joinLink" ]
                    , H.text "."
                    ]
                , H.h3
                    [ A.class "registration__input" ]
                    [ H.input
                        [ A.name "email"
                        , A.type_ "email"
                        , A.autofocus True
                        , A.placeholder <|
                            t "registration.emailPlaceholder"
                        , onInput Email
                        ]
                        []
                    ]
                , H.div
                    [ A.class "registration__consent" ]
                    [ H.input
                        [ A.type_ "checkbox"
                        , A.class "registration__consent-checkbox"
                        , onClick ToggleConsent
                        ]
                        []
                    , H.div [ A.class "registration__consent-text" ]
                        [ H.text (t "registration.consentText")
                        ]
                    ]
                , errorMessage
                    |> Maybe.map
                        (\message ->
                            H.p [ A.class "error" ] [ H.text message ]
                        )
                    |> Maybe.withDefault (H.text "")
                , H.p
                    [ A.class "registration__submit-button" ]
                    [ H.button
                        [ A.type_ "submit"
                        , A.class "btn btn-primary"
                        , A.disabled (String.length model.email == 0 || not model.consent)
                        ]
                        [ H.text <| t "registration.buttonText" ]
                    ]
                ]
            ]
        ]


view : T -> Model -> H.Html Msg
view t model =
    case model.status of
        NotLoaded ->
            registrationForm t model Nothing

        Success ->
            H.div
                [ A.class "container last-row" ]
                [ H.div
                    [ A.class "row registration col-sm-6 col-sm-offset-3" ]
                    [ H.div
                        [ A.class "registration__container"
                        ]
                        [ H.h1
                            [ A.class "registration__heading" ]
                            [ H.text <| t "registration.success" ]
                        ]
                    ]
                ]

        Failure ->
            registrationForm t model <|
                Just (t "registration.failure")

        NetworkError ->
            registrationForm t model <|
                Just (t "registration.networkError")
