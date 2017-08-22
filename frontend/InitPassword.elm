module InitPassword exposing (..)

import Html as H
import Html.Attributes as A
import Html.Events exposing (onInput, onWithOptions)
import Http
import Json.Decode
import Json.Decode.Pipeline exposing (decode, required)
import Json.Encode
import State.InitPassword exposing (..)
import Translation exposing (T)
import Util exposing (UpdateMessage(..))


type Msg
    = Password String
    | Password2 String
    | Submitted (Maybe String)
    | SendResponse (Result Http.Error Response)


type alias Response =
    { status : String }


submit : Model -> Maybe String -> Cmd Msg
submit model maybeToken =
    let
        encoded =
            Json.Encode.object <|
                [ ( "password", Json.Encode.string model.password )
                , ( "password2", Json.Encode.string model.password2 )
                , ( "token", Json.Encode.string (Maybe.withDefault "" maybeToken) )
                ]
    in
    Http.post "/initpassword" (Http.jsonBody encoded) decodeResponse
        |> Http.send SendResponse


decodeResponse : Json.Decode.Decoder Response
decodeResponse =
    decode Response
        |> required "status" Json.Decode.string


update : Msg -> Model -> ( Model, Cmd (UpdateMessage Msg) )
update msg model =
    case msg of
        Password str ->
            { model | password = str } ! []

        Password2 str ->
            { model | password2 = str } ! []

        SendResponse (Err error) ->
            { model | status = Failure } ! []

        SendResponse (Ok response) ->
            { model | status = Success } ! []

        Submitted maybeToken ->
            model ! [ Cmd.map LocalUpdateMessage <| submit model maybeToken ]


view : T -> Model -> Maybe String -> H.Html Msg
view t model maybeToken =
    case model.status of
        NotLoaded ->
            H.div
                [ A.class "container last-row" ]
                [ H.div
                    [ A.class "row initpassword col-sm-6 col-sm-offset-3" ]
                    [ H.form
                        [ A.class "initpassword__container"
                        , onWithOptions "submit"
                            { preventDefault = True, stopPropagation = False }
                            (Json.Decode.succeed (Submitted maybeToken))
                        ]
                        [ H.h1
                            [ A.class "initpassword__heading" ]
                            [ H.text <| t "initPassword.title" ]
                        , H.h3
                            [ A.class "initpassword__input" ]
                            [ H.input [ A.type_ "password", A.autofocus True, A.placeholder <| t "initPassword.passwordPlaceholder", onInput Password ] []
                            ]
                        , H.h3
                            [ A.class "initpassword__input" ]
                            [ H.input [ A.type_ "password", A.placeholder <| t "initPassword.password2Placeholder", onInput Password2 ] []
                            ]
                        , H.p
                            [ A.class "initpassword__submit-button" ]
                            [ H.button
                                [ A.type_ "submit"
                                , A.class "btn btn-primary"
                                , A.disabled (String.length model.password == 0 || (model.password /= model.password2))
                                ]
                                [ H.text <| t "initPassword.buttonSubmit" ]
                            ]
                        ]
                    ]
                ]

        Success ->
            H.div
                [ A.class "container last-row" ]
                [ H.div
                    [ A.class "row initpassword col-sm-6 col-sm-offset-3" ]
                    [ H.div
                        [ A.class "initpassword__container"
                        ]
                        [ H.h1
                            [ A.class "initpassword__heading" ]
                            [ H.text <| t "initPassword.success" ]
                        , H.p
                            []
                            [ H.text <| t "initPassword.successMessage" ]
                        ]
                    ]
                ]

        Failure ->
            H.div
                [ A.class "container last-row" ]
                [ H.div
                    [ A.class "row initpassword col-sm-6 col-sm-offset-3" ]
                    [ H.div
                        [ A.class "initpassword__container"
                        ]
                        [ H.h1
                            [ A.class "initpassword__heading" ]
                            [ H.text <| t "initPassword.failure" ]
                        ]
                    ]
                ]
