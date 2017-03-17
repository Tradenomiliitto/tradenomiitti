module Profile.View exposing (..)

import Html as H
import Html.Attributes as A
import Html.Events as E
import Json.Decode as Json
import Link exposing (AppMessage(..))
import ListAds
import Nav
import Profile.Main exposing (Msg(..))
import Skill
import State.Main as RootState
import State.Profile exposing (Model)
import Models.User exposing (User)

view : Model -> RootState.Model ->  H.Html (AppMessage Msg)
view model rootState =
  H.div [ A.class "user-page" ] <|
    [ profileTopRow model rootState
    ] ++ (viewUserMaybe model)


profileTopRow : Model -> RootState.Model -> H.Html (AppMessage Msg)
profileTopRow model rootState =
  let
    link =
      case model.user of
        Just _ ->
          H.a
            [ A.href "/uloskirjautuminen"
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
      case model.user of
        Just user ->
          H.button
            [ A.class "btn btn-primary profile__top-row-edit-button"
            , E.onClick <| if model.editing then LocalMessage (Save user) else LocalMessage Edit
            ]
            [ H.text (if model.editing then "Tallenna profiili" else "Muokkaa profiilia") ]
        Nothing ->
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

viewUserMaybe : Model -> List (H.Html (AppMessage Msg))
viewUserMaybe model =
  model.user
    |> Maybe.map (viewUser model)
    |> Maybe.withDefault
      [ H.div
        [ A.class "container"]
          [ H.div [ A.class "row user-page__section" ]
            [ H.text "Et ole kirjautunut" ]
          ]
      ]


viewUser : Model -> User -> List (H.Html (AppMessage Msg))
viewUser model user =
  [ H.div
    [ A.class "container" ]
    [ H.div
      [ A.class "row user-page__section" ]
      [ H.map LocalMessage (userInfoBox model user)
      , H.map LocalMessage (membershipDataBox user)
      ]
    ]
  , H.hr [ A.class "full-width-ruler" ] []
  , H.div
    [ A.class "container" ] <|
    [ H.div
      [ A.class "row" ]
      [ H.div
        [ A.class "col-sm-12" ]
        [ H.h3 [ A.class "user-page__activity-header" ] [ H.text "Aktiivisuus" ]
        ]
      ]
    ]
    ++ ListAds.viewAds model.ads
  , H.hr [ A.class "full-width-ruler" ] []
  , H.div
    [ A.class "container" ]
    [ H.div
      [ A.class "row" ]
      [ H.map LocalMessage (userDomains model user)
      , H.map LocalMessage (userPositions model user)
      ]
    ]
  ]

userInfoBox : Model -> User -> H.Html Msg
userInfoBox model user =
  H.div
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
                  , E.onInput ChangeNickname
                  ] []
                else
                  H.text user.name
              ]
          , H.p
            [ A.class "user-page__work-details" ]
            [ if model.editing
              then
                H.input
                [ A.value user.primaryPosition
                , E.on "change" (Json.map ChangeTitle E.targetValue)
                ]
                []
              else H.text user.primaryPosition
            ]
          ]
        ]
      ]
    , userDescription model user
    ]


userDescription : Model -> User -> H.Html Msg
userDescription model user =
  H.div
    [ A.class "row user-page__description" ]
    [ H.p [ A.class "col-xs-12" ]
      [ if model.editing
        then
          H.textarea [ A.value user.description
                      , A.placeholder "Kirjoita napakka kuvaus itsestäsi"
                      , A.class "user-page__description-input"
                      , E.onInput ChangeDescription
                      ] []
        else
          H.text user.description
      ]
    ]

userDomains : Model -> User -> H.Html Msg
userDomains model user =
  H.div
    [ A.class "col-xs-12 col-sm-6"
    ]
    ([ H.h3 [ A.class "user-page__competences-header" ] [ H.text "Toimiala" ]
    ] ++
      (List.indexedMap
        (\i x -> H.map (DomainSkillMessage i) <|
          Skill.view model.editing x)
            user.domains
    ) ++
    (if model.editing
      then
        [ H.select
          [ E.on "change" (Json.map ChangeDomainSelect E.targetValue)] <|
            H.option [] [ H.text "Valitse toimiala"] :: List.map (\o -> H.option [] [ H.text o ]) model.domainOptions
            , H.button
              [ A.class "btn"
              , E.onClick AddDomain
              ]
              [ H.text "Lisää toimiala"]
              ]
      else [])
    )

userPositions : Model -> User -> H.Html Msg
userPositions model user =
  H.div
    [ A.class "col-xs-12 col-sm-6"
    ]
    ([ H.h3 [ A.class "user-page__competences-header" ] [ H.text "Tehtäväluokka" ]
      ] ++
        (List.indexedMap
          (\i x -> H.map (PositionSkillMessage i) <| Skill.view model.editing x)
          user.positions
        ) ++
        (if model.editing
          then
            [ H.select
              [ E.on "change" (Json.map ChangePositionSelect E.targetValue)] <|
              H.option [] [ H.text "Valitse tehtäväluokka"] :: List.map (\o -> H.option [] [ H.text o ]) model.positionOptions
            , H.button
            [ A.class "btn"
            , E.onClick AddPosition
            ]
            [ H.text "Lisää tehtäväluokka"]
            ]
          else [])
    )

membershipDataBox : User -> H.Html msg
membershipDataBox user =
  case user.extra of
    Just extra ->
      H.div
        [ A.class "col-md-6 user-page__membership-info" ]
        [ H.h3 [ A.class "user-page__membership-info-heading" ] [ H.text "Jäsentiedot:" ]
        , H.span [] [ H.text "(eivät näy muille)"]
        , H.table
          [ A.class "user-page__membership-info-definitions" ]
          [ H.tr []
              [ H.td [] [ H.text "Kutsumanimi" ]
              , H.td [] [ H.text extra.nick_name ]
              ]
          , H.tr []
            [ H.td [] [ H.text "Etunimi" ]
            , H.td [] [ H.text extra.first_name ]
            ]
          , H.tr []
            [ H.td [] [ H.text "Tehtäväluokat" ]
            , H.td [] [ H.text (String.join ", " extra.positions)]
            ]
          , H.tr []
            [ H.td [] [ H.text "Toimiala" ]
            , H.td [] [ H.text (String.join ", " extra.domains) ]
            ]
          ]
        , H.p [] [ H.text "Ovathan jäsentietosi ajan tasalla?" ]
        , H.p [] [ H.a
                     [ A.href "https://asiointi.tral.fi/" ]
                     [ H.text "Päivitä tiedot" ]
                 ]
        ]
    Nothing ->
      H.div
        [ A.class "col-md-6 user-page__membership-info" ]
        [ H.h3 [ A.class "user-page__membership-info-heading" ] [ H.text "Jäsentiedot puuttuvat" ]
        ]
