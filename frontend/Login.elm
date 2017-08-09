module Login exposing (..)

import Html as H
import Html.Attributes as A
import Html.Events exposing (onInput, onSubmit, onWithOptions)
import Http
import Json.Decode
import Json.Decode.Pipeline exposing (decode, required)
import Json.Encode
import Nav
import Profile.Main as Profile
import State.Login exposing (..)
import Translation exposing (T)
import Util exposing (UpdateMessage(..))


type Msg
    = Name String
    | Password String



--    | SendResponse (Result Http.Error Response)
--    | Submitted
--type alias Response =
--    { status : String }
--submit : Model -> Cmd Msg
--submit model =
--    let
--        encoded =
--            Json.Encode.object <|
--                [ ( "username", Json.Encode.string model.username )
--                , ( "password", Json.Encode.string model.password )
--                ]
--    in
--    Http.post "/kirjaudu" (Http.jsonBody encoded) decodeResponse
--        |> Http.send SendResponse
--decodeResponse : Json.Decode.Decoder Response
--decodeResponse =
--    decode Response
--        |> required "status" Json.Decode.string


update : Msg -> Model -> ( Model, Cmd (UpdateMessage Msg) )
update msg model =
    case msg of
        Name username ->
            { model | username = username } ! []

        Password password ->
            { model | password = password } ! []



--SendResponse (Err error) ->
--    model ! []
--SendResponse (Ok response) ->
--    model ! [ Util.reroute Nav.Home ]
--Submitted ->
--    model ! [ Cmd.map LocalUpdateMessage <| submit model ]


view : T -> Model -> H.Html Msg
view t model =
    H.div
        [ A.class "container last-row" ]
        [ H.div
            [ A.class "row login col-sm-6 col-sm-offset-3" ]
            [ H.form
                [ A.class "login__container", A.action "/kirjaudu", A.method "post" ]
                [ H.h1
                    [ A.class "login__heading" ]
                    [ H.text <| t "login.title" ]
                , H.h3
                    [ A.class "login__input" ]
                    [ H.input [ A.name "username", A.type_ "text", A.placeholder <| t "login.usernamePlaceholder", onInput Name ] []
                    ]
                , H.h3
                    [ A.class "login__input" ]
                    [ H.input [ A.name "password", A.type_ "password", A.placeholder <| t "login.passwordPlaceholder", onInput Password ] []
                    ]
                , H.p
                    [ A.class "login__submit-button" ]
                    [ H.button
                        [ A.type_ "submit"
                        , A.class "btn btn-primary"
                        , A.disabled (String.length model.username == 0 || String.length model.password == 0)
                        ]
                        [ H.text <| t "common.login" ]
                    ]
                ]
            ]
        ]
