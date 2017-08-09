module ChangePassword exposing (..)

import Html as H
import Html.Attributes as A
import Html.Events exposing (onInput, onSubmit, onWithOptions)
import Http
import Json.Decode
import Json.Decode.Pipeline exposing (decode, required)
import Json.Encode
import Models.User exposing (User)
import Nav
import Profile.Main as Profile
import State.ChangePassword exposing (..)
import Translation exposing (T)
import Util exposing (UpdateMessage(..))


type Msg
    = OldPassword String
    | NewPassword String
    | NewPassword2 String
    | SendResponse (Result Http.Error Response)
    | Submitted


type alias Response =
    { status : String }


submit : Model -> Cmd Msg
submit model =
    let
        encoded =
            Json.Encode.object <|
                [ ( "oldPassword", Json.Encode.string model.oldPassword )
                , ( "newPassword", Json.Encode.string model.newPassword )
                , ( "newPassword2", Json.Encode.string model.newPassword2 )
                ]
    in
    Http.post "/vaihdasalasana" (Http.jsonBody encoded) decodeResponse
        |> Http.send SendResponse


decodeResponse : Json.Decode.Decoder Response
decodeResponse =
    decode Response
        |> required "status" Json.Decode.string


update : Msg -> Model -> ( Model, Cmd (UpdateMessage Msg) )
update msg model =
    case msg of
        OldPassword password ->
            { model | oldPassword = password } ! []

        NewPassword password ->
            { model | newPassword = password } ! []

        NewPassword2 password ->
            { model | newPassword2 = password } ! []

        SendResponse (Err error) ->
            model ! []

        SendResponse (Ok response) ->
            { model | status = Success } ! []

        Submitted ->
            model ! [ Cmd.map LocalUpdateMessage <| submit model ]


view : T -> Model -> Maybe User -> H.Html Msg
view t model maybeUser =
    case maybeUser of
        Just user ->
            case model.status of
                NotLoaded ->
                    H.div
                        [ A.class "container last-row" ]
                        [ H.div
                            [ A.class "row login col-sm-6 col-sm-offset-3" ]
                            [ H.form
                                --[ A.class "login__container"
                                --, A.action "/changepassword"
                                --, A.method "post"
                                --]
                                [ A.class "login__container"
                                , onWithOptions "submit"
                                    { preventDefault = True, stopPropagation = False }
                                    (Json.Decode.succeed Submitted)
                                ]
                                [ H.h1
                                    [ A.class "login__heading" ]
                                    [ H.text <| t "changePassword.title" ]
                                , H.h3
                                    [ A.class "login__input" ]
                                    [ H.input [ A.name "oldpassword", A.type_ "password", A.placeholder <| t "changePassword.oldPasswordPlaceholder", onInput OldPassword ] []
                                    ]
                                , H.h3
                                    [ A.class "login__input" ]
                                    [ H.input [ A.name "newpassword", A.type_ "password", A.placeholder <| t "changePassword.newPasswordPlaceholder", onInput NewPassword ] []
                                    ]
                                , H.h3
                                    [ A.class "login__input" ]
                                    [ H.input [ A.name "newpassword2", A.type_ "password", A.placeholder <| t "changePassword.newPasswordPlaceholder2", onInput NewPassword2 ] []
                                    ]
                                , H.p
                                    [ A.class "login__submit-button" ]
                                    [ H.button
                                        [ A.type_ "submit"
                                        , A.class "btn btn-primary"
                                        , A.disabled ((String.length model.oldPassword == 0 || String.length model.newPassword == 0) || (model.newPassword /= model.newPassword2))
                                        ]
                                        [ H.text <| t "changePassword.submit" ]
                                    ]
                                ]
                            ]
                        ]

                Success ->
                    H.div
                        [ A.class "container last-row" ]
                        [ H.div
                            [ A.class "row login col-sm-6 col-sm-offset-3" ]
                            [ H.div
                                [ A.class "login__container"
                                ]
                                [ H.h1
                                    [ A.class "login__heading" ]
                                    [ H.text <| t "changePassword.success" ]
                                ]
                            ]
                        ]

        Nothing ->
            H.div [] []
