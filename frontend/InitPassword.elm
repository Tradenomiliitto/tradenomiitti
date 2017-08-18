module InitPassword exposing (..)

import Html as H
import Html.Attributes as A
import Html.Events exposing (onInput, onSubmit, onWithOptions)
import Http
import Json.Decode
import Json.Decode.Pipeline exposing (decode, required)
import Json.Encode
import State.InitPassword exposing (..)
import Translation exposing (T)
import Util exposing (UpdateMessage(..))


type Msg
    = Password String
    | Submitted
    | SendResponse (Result Http.Error Response)


type alias Response =
    { status : String }


submit : Model -> Cmd Msg
submit model =
    let
        encoded =
            Json.Encode.object <|
                [ ( "password", Json.Encode.string model.password )
                , ( "token", Json.Encode.string "asdfkhjasdöofhasdlkj788787" )
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
        Password password ->
            { model | password = password } ! []

        SendResponse (Err error) ->
            { model | status = Failure } ! []

        SendResponse (Ok response) ->
            { model | status = Success } ! []

        Submitted ->
            model ! [ Cmd.map LocalUpdateMessage <| submit model ]



-- Näytä success/failure -> message, jonka serveri lähettää?


view : T -> Model -> H.Html Msg
view t model =
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
                            (Json.Decode.succeed Submitted)
                        ]
                        [ H.h1
                            [ A.class "initpassword__heading" ]
                            [ H.text <| t "initPassword.title" ]
                        , H.h3
                            [ A.class "initpassword__input" ]
                            [ H.input [ A.type_ "password", A.placeholder <| t "initPassword.passwordPlaceholder", onInput Password ] []
                            ]
                        , H.p
                            [ A.class "initpassword__submit-button" ]
                            [ H.button
                                [ A.type_ "submit"
                                , A.class "btn btn-primary"
                                , A.disabled (String.length model.password == 0)
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
