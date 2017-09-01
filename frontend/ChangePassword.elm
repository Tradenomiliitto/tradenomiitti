module ChangePassword exposing (..)

import Common
import Html as H
import Html.Attributes as A
import Html.Events exposing (onInput, onWithOptions)
import Http
import Json.Decode
import Json.Decode.Pipeline exposing (decode, required)
import Json.Encode
import Models.User exposing (User)
import State.ChangePassword exposing (..)
import Translation exposing (T)
import Util exposing (UpdateMessage(..), ViewMessage(..))


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


changePasswordForm : T -> Model -> User -> Maybe String -> H.Html (ViewMessage Msg)
changePasswordForm t model user errorMessage =
    H.div
        []
        [ Common.profileTopRow t user False Common.ChangePasswordTab (H.div [] [])
        , H.div
            [ A.class "container last-row" ]
            [ H.div
                [ A.class "row changepassword col-sm-6 col-sm-offset-3" ]
                [ H.form
                    [ A.class "changepassword__container"
                    , onWithOptions "submit"
                        { preventDefault = True, stopPropagation = False }
                        (Json.Decode.succeed (LocalViewMessage Submitted))
                    ]
                    [ H.h1
                        [ A.class "changepassword__heading" ]
                        [ H.text <| t "changePassword.title" ]
                    , H.h3
                        [ A.class "changepassword__input" ]
                        [ H.input
                            [ A.name "oldpassword"
                            , A.type_ "password"
                            , A.autofocus True
                            , A.placeholder <|
                                t "changePassword.oldPasswordPlaceholder"
                            , onInput (LocalViewMessage << OldPassword)
                            ]
                            []
                        ]
                    , H.h3
                        [ A.class "changepassword__input" ]
                        [ H.input
                            [ A.name "newpassword"
                            , A.type_ "password"
                            , A.placeholder <|
                                t "changePassword.newPasswordPlaceholder"
                            , onInput (LocalViewMessage << NewPassword)
                            ]
                            []
                        ]
                    , H.h3
                        [ A.class "changepassword__input" ]
                        [ H.input
                            [ A.name "newpassword2"
                            , A.type_ "password"
                            , A.placeholder <|
                                t "changePassword.newPasswordPlaceholder2"
                            , onInput (LocalViewMessage << NewPassword2)
                            ]
                            []
                        ]
                    , errorMessage
                        |> Maybe.map
                            (\message ->
                                H.p [ A.class "error" ] [ H.text message ]
                            )
                        |> Maybe.withDefault (H.text "")
                    , H.p
                        [ A.class "changepassword__submit-button" ]
                        [ H.button
                            [ A.type_ "submit"
                            , A.class "btn btn-primary"
                            , A.disabled
                                ((String.length model.oldPassword == 0 || String.length model.newPassword == 0)
                                    || (model.newPassword /= model.newPassword2)
                                )
                            ]
                            [ H.text <| t "changePassword.submit" ]
                        ]
                    ]
                ]
            ]
        ]


view : T -> Model -> Maybe User -> H.Html (ViewMessage Msg)
view t model maybeUser =
    case maybeUser of
        Just user ->
            case model.status of
                NotLoaded ->
                    changePasswordForm t model user Nothing

                Failure ->
                    changePasswordForm t model user <|
                        Just (t "changePassword.failure")

                NetworkError ->
                    changePasswordForm t model user <|
                        Just (t "changePassword.networkError")

                Success ->
                    H.div
                        []
                        [ Common.profileTopRow t user False Common.ChangePasswordTab (H.div [] [])
                        , H.div
                            [ A.class "container last-row" ]
                            [ H.div
                                [ A.class "row changepassword col-sm-6 col-sm-offset-3" ]
                                [ H.div
                                    [ A.class "changepassword__container"
                                    ]
                                    [ H.h1
                                        [ A.class "changepassword__heading" ]
                                        [ H.text <| t "changePassword.success" ]
                                    ]
                                ]
                            ]
                        ]

        Nothing ->
            H.div [] []
