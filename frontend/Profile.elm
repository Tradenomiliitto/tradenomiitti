module Profile exposing (..)

import Html as H
import Html.Attributes as A
import Http
import Nav
import State.Main as RootState
import User

type alias Model =
  { user : User.Model
  }

getMe : ((Result Http.Error User.User) -> msg) -> Cmd msg
getMe toMsg =
  Http.get "/api/me" User.userDecoder
    |> Http.send toMsg


view : User.Model -> RootState.Model -> (User.Msg -> msg) -> H.Html msg
view userModel rootState toMsg =
  H.div
    []
    [ profileTopRow rootState
    , H.map toMsg <| User.view userModel
    ]

profileTopRow : RootState.Model -> H.Html msg
profileTopRow model =
  let
    link =
      case model.profile.user of
        Just _ ->
          H.a
            [ A.href "/logout"
            , A.class "btn"
            ]
            [ H.text "Kirjaudu ulos" ]
        Nothing ->
          H.a
            [ A.href <| Nav.ssoUrl model.rootUrl model.route
            , A.class "btn"
            ]
            [ H.text "Kirjaudu sisään" ]
  in
    H.div
      [ A.class "row profile__top-row" ]
      [ H.div
        [ A.class "container" ]
        [ H.div
          [ A.class "row" ]
          [ H.div
            [ A.class "col-xs-4" ]
            [ H.h4
                [ A.class "profile__heading" ]
                [ H.text "Oma profiili" ] ]
          , H.div
            [ A.class "col-xs-8 profile__buttons" ]
            [ H.button
                [ A.class "btn btn-primary" ]
                [ H.text "Tallenna profiili" ]
            , link
            ]
          ]
        ]
      ]
