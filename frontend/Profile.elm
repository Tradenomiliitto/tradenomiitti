module Profile exposing (..)

import Html as H
import Html.Attributes as A
import Html.Events as E
import Http
import Maybe.Extra as Maybe
import Nav
import State.Main as RootState
import State.Profile exposing (Model)
import User


type Msg
  = GetMe (Result Http.Error User.User)
  | Save
  | Edit
  | NoOp


getMe : Cmd Msg
getMe =
  Http.get "/api/me" User.userDecoder
    |> Http.send GetMe

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    GetMe (Err _) ->
      { model | user = Nothing } ! []

    GetMe (Ok user) ->
      { model | user = Just user } ! []

    Save ->
      { model | editing = False } ! [] -- TODO

    Edit ->
      { model | editing = True } ! []

    NoOp ->
      model ! []


view : Model -> RootState.Model ->  H.Html Msg
view model rootState =
  H.div
    []
    [ profileTopRow model rootState
    , viewUserMaybe model
    ]

profileTopRow : Model -> RootState.Model -> H.Html Msg
profileTopRow model rootState =
  let
    link =
      case model.user of
        Just _ ->
          H.a
            [ A.href "/logout"
            , A.class "btn"
            ]
            [ H.text "Kirjaudu ulos" ]
        Nothing ->
          H.a
            [ A.href <| Nav.ssoUrl rootState.rootUrl Nav.Profile
            , A.class "btn"
            ]
            [ H.text "Kirjaudu sisään" ]

    saveOrEdit =
      if Maybe.isJust model.user
      then
        H.button
          [ A.class "btn btn-primary"
          , E.onClick <| if model.editing then Save else Edit
          ]
          [ H.text (if model.editing then "Tallenna profiili" else "Muokkaa profiilia") ]
      else
        H.div [] []
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
            [ saveOrEdit
            , link
            ]
          ]
        ]
      ]

viewUserMaybe : Model -> H.Html Msg
viewUserMaybe model =
  model.user
    |> Maybe.map viewUser
    |> Maybe.withDefault (H.div [] [])


viewUser : User.User -> H.Html Msg
viewUser user =
  H.div
    [ A.class "container" ]
    [ H.h1 [] [ H.text "Profiili" ]
    , H.p [] [ H.text "Alla olevat tiedot on täytetty jäsentiedoistasi" ]
    , viewProfileForm user
    ]

viewProfileForm : User.User -> H.Html Msg
viewProfileForm user =
  H.form
    []
    [ H.div
        [ A.class "form-group"]
        [ H.label [] [ H.text "Millä nimellä meidän tulisi kutsua sinua?" ]
        , H.input
          [ A.value user.name
          , A.class "form-control"
          , E.onInput <| always NoOp
          ] []
        ]
    , H.div
      [ A.class "form-group" ]
      [ H.label [] [ H.text "Kuvaile itseäsi" ]
      , H.input
        [ A.value user.description
        , A.class "form-control"
        , E.onInput <| always NoOp
        ] []
      ]
    , H.div
      [ A.class "form-group" ]
      ([ H.label [] [ H.text "Tehtävät, joista sinulla on kokemusta" ]] ++
         viewPositions user.positions)
    ]

viewPositions : List String -> List (H.Html Msg)
viewPositions positions =
  List.map (\position -> H.input
              [ A.value position
              , A.class "form-control"
              , E.onInput <| always NoOp
              ] []) positions
