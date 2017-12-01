module RenewPassword exposing (..)

import Html as H
import Html.Attributes as A
import Html.Events exposing (onInput, onWithOptions)
import Html.Keyed
import Http
import Json.Decode
import Json.Decode.Pipeline exposing (decode, required)
import Json.Encode
import State.RenewPassword exposing (..)
import Translation exposing (T)
import Util exposing (UpdateMessage(..))


type Msg
    = Email String
    | Submitted
    | SendResponse (Result Http.Error Response)


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
    Http.post "/salasanaunohtui" (Http.jsonBody encoded) decodeResponse
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

        SendResponse (Ok response) ->
            { model | status = Success } ! []

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

        Submitted ->
            model ! [ Cmd.map LocalUpdateMessage <| submit model ]


renewPasswordForm : T -> Model -> Maybe String -> H.Html Msg
renewPasswordForm t model errorMessage =
    H.div
        [ A.class "container last-row" ]
        [ H.div
            [ A.class "row renewpassword col-sm-6 col-sm-offset-3" ]
            [ H.form
                [ A.class "renewpassword__container"
                , onWithOptions "submit"
                    { preventDefault = True, stopPropagation = False }
                    (Json.Decode.succeed Submitted)
                ]
                [ H.h1
                    [ A.class "renewpassword__heading" ]
                    [ H.text <| t "renewPassword.title" ]
                , H.p [] [ H.text <| t "renewPassword.hint" ]
                , H.h3
                    [ A.class "renewpassword__input" ]
                    [ Html.Keyed.node "input"
                        [ A.name "email"
                        , A.type_ "email"
                        , A.autofocus True
                        , A.placeholder <|
                            t "renewPassword.emailPlaceholder"
                        , onInput Email
                        ]
                        []
                    ]
                , errorMessage
                    |> Maybe.map
                        (\message ->
                            H.p [ A.class "renewpassword__error" ] [ H.text message ]
                        )
                    |> Maybe.withDefault (H.text "")
                , H.p
                    [ A.class "renewpassword__submit-button" ]
                    [ H.button
                        [ A.type_ "submit"
                        , A.class "btn btn-primary"
                        , A.disabled (String.length model.email == 0)
                        ]
                        [ H.text <| t "renewPassword.buttonText" ]
                    ]
                ]
            ]
        ]


view : T -> Model -> H.Html Msg
view t model =
    case model.status of
        NotLoaded ->
            renewPasswordForm t model Nothing

        Success ->
            H.div
                [ A.class "container last-row" ]
                [ H.div
                    [ A.class "row renewpassword col-sm-6 col-sm-offset-3" ]
                    [ H.div
                        [ A.class "renewpassword__container" ]
                        [ H.h1
                            [ A.class "renewpassword__heading" ]
                            [ H.text <| t "renewPassword.success" ]
                        ]
                    ]
                ]

        Failure ->
            renewPasswordForm t model <|
                Just (t "renewPassword.failure")

        NetworkError ->
            renewPasswordForm t model <|
                Just (t "renewPassword.networkError")
