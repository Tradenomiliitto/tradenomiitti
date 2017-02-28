module Profile exposing (..)

import Html as H
import Html.Attributes as A
import Html.Events as E
import Http
import Maybe.Extra as Maybe
import Nav
import Skill
import State.Main as RootState
import State.Profile exposing (Model)
import User


type Msg
  = GetMe (Result Http.Error User.User)
  | Save
  | Edit
  | DomainSkillMessage Int Skill.SkillLevel
  | PositionSkillMessage Int Skill.SkillLevel
  | AddDomain
  | AddPosition
  | NoOp


getMe : Cmd Msg
getMe =
  Http.get "/api/me" User.userDecoder
    |> Http.send GetMe


updateSkillList : Int -> Skill.SkillLevel -> List Skill.Model -> List Skill.Model
updateSkillList index skillLevel list =
  List.indexedMap
    (\i x -> if i == index then Skill.update skillLevel x else x)
    list

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

    DomainSkillMessage index skillLevel ->
      { model | domains = updateSkillList index skillLevel model.domains } ! []

    PositionSkillMessage index skillLevel ->
      { model | positions = updateSkillList index skillLevel model.positions } ! []

    AddDomain ->
      model ! []

    AddPosition ->
      model ! []

    NoOp ->
      model ! []


view : Model -> RootState.Model ->  H.Html Msg
view model rootState =
  H.div [ A.class "user-page" ] <|
    [ profileTopRow model rootState
    ] ++ (viewUserMaybe model)


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
          [ A.class "btn btn-primary profile__top-row-edit-button"
          , E.onClick <| if model.editing then Save else Edit
          ]
          [ H.text (if model.editing then "Tallenna profiili" else "Muokkaa profiilia") ]
      else
        H.div [] []
  in
    H.div
      [ A.classList
          [ ("row", True)
          , ("profile__top-row", True)
          , ("profile__top-row--editing", model.editing)
          ]
      ]
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

viewUserMaybe : Model -> List (H.Html Msg)
viewUserMaybe model =
  model.user
    |> Maybe.map (viewUser model)
    |> Maybe.withDefault []


viewUser : Model -> User.User -> List (H.Html Msg)
viewUser model user =
  [ H.div
    [ A.class "container" ]
    [ H.div
      [ A.class "row user-page__section" ]
      [ H.div
        [ A.class "col-md-6" ]
        [ H.div
          [ A.class "row" ]
          [ H.div
            [ A.class "col-xs-12"]
            [ H.div
              [ A.class "pull-left user-page__pic-container" ]
              [ H.span [ A.class "user-page__pic" ] [] ]
            , H.div
              [ A.class "pull-left" ]
              [ H.h4 [ A.class "user-page__name" ]
                  [ if model.editing
                    then
                      H.input [ A.placeholder "Miksi kutsumme sinua?"
                              , A.value user.name
                              ] []
                    else
                      H.text user.name
                  ]
              , H.p
                [ A.class "user-page__work-details" ]
                [ H.text user.primaryDomain
                , H.br [] []
                , H.text user.primaryPosition
                ]
              ]
            ]
          ]
        , H.div
          [ A.class "row user-page__description" ]
          [ H.p [ A.class "col-xs-12" ]
              [ if model.editing
                then
                  H.textarea [ A.value user.description
                             , A.placeholder "Kirjoita napakka kuvaus itsestäsi"
                             , A.class "user-page__description-input"
                             ] []
                else
                  H.text user.description
              ]
          ]
        ]
      , H.div
        [ A.class "col-md-6 user-page__membership-info" ]
        [ H.h3 [ A.class "user-page__membership-info-heading" ] [ H.text "Jäsentiedot:" ]
        , H.span [] [ H.text "(eivät näy muille)"]
        , H.table
          [ A.class "user-page__membership-info-definitions" ]
          [ H.tr []
              [ H.td [] [ H.text "Kutsumanimi" ]
              , H.td [] [ H.text user.extra.nick_name ]
              ]
          , H.tr []
            [ H.td [] [ H.text "Etunimi" ]
            , H.td [] [ H.text user.extra.first_name ]
            ]
          , H.tr []
            [ H.td [] [ H.text "Tehtäväluokat" ]
            , H.td [] [ H.text (String.join ", " user.extra.positions)]
            ]
          , H.tr []
            [ H.td [] [ H.text "Toimiala" ]
            , H.td [] [ H.text (String.join ", " user.extra.domains) ]
            ]
          ]
        , H.p [] [ H.text "Ovathan jäentietosi ajan tasalla?" ]
        , H.p [] [ H.a
                     [ A.href "https://asiointi.tral.fi/" ]
                     [ H.text "Päivitä tiedot" ]
                 ]
        ]
      ]
    ]
  , H.hr [] []
  , H.div
    [ A.class "container" ]
    [ H.div
      [ A.class "row" ]
      [ H.div
          [ A.class "col-xs-12 col-sm-6"
          ]
          ([ H.h3 [ A.class "user-page__competences-header" ] [ H.text "Toimiala" ]
          ] ++
             (List.indexedMap
                (\i x -> H.map (DomainSkillMessage i) <|
                   Skill.view model.editing x)
                model.domains
             ) ++
             (if model.editing
              then
                [ H.button
                  [ A.class "btn"
                  , E.onClick AddDomain
                  ]
                  [ H.text "Lisää toimiala"]
                ]
              else [])
          )
      , H.div
          [ A.class "col-xs-12 col-sm-6"
          ]
          ([ H.h3 [ A.class "user-page__competences-header" ] [ H.text "Tehtäväluokka" ]
           ] ++
             (List.indexedMap
                (\i x -> H.map (PositionSkillMessage i) <| Skill.view model.editing x)
                model.positions
             ) ++
             (if model.editing
              then
                [ H.button
                  [ A.class "btn"
                  , E.onClick AddPosition
                  ]
                  [ H.text "Lisää tehtäväluokka"]
                ]
              else [])
          )
      ]
    ]
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
         viewPositions user.extra.positions)
    ]

viewPositions : List String -> List (H.Html Msg)
viewPositions positions =
  List.map (\position -> H.input
              [ A.value position
              , A.class "form-control"
              , E.onInput <| always NoOp
              ] []) positions
