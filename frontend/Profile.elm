module Profile exposing (..)

import Html as H
import Html.Attributes as A
import Html.Events as E
import Http
import Json.Decode as Json
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
  | ChangeDomainSelect String
  | ChangePositionSelect String
  | AddDomain
  | AddPosition
  | GetDomainOptions (Result Http.Error (List String))
  | GetPositionOptions (Result Http.Error (List String))
  | ChangePrimaryDomain String
  | ChangePrimaryPosition String
  | ChangeNickname String
  | ChangeDescription String
  | NoOp


getMe : Cmd Msg
getMe =
  Http.get "/api/me" User.userDecoder
    |> Http.send GetMe

initTasks : Cmd Msg
initTasks =
  Cmd.batch [ getPositionOptions, getDomainOptions ]

getDomainOptions : Cmd Msg
getDomainOptions =
  Http.get "/api/domains" (Json.list Json.string)
    |> Http.send GetDomainOptions

getPositionOptions : Cmd Msg
getPositionOptions =
  Http.get "/api/positions" (Json.list Json.string)
    |> Http.send GetPositionOptions


updateSkillList : Int -> Skill.SkillLevel -> List Skill.Model -> List Skill.Model
updateSkillList index skillLevel list =
  List.indexedMap
    (\i x -> if i == index then Skill.update skillLevel x else x)
    list

updateUser : (User.User -> User.User) -> Model -> Model
updateUser update model =
  { model | user = Maybe.map update model.user }

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
      updateUser (\u -> { u | domains = updateSkillList index skillLevel u.domains }) model ! []

    PositionSkillMessage index skillLevel ->
      updateUser (\u -> { u | domains = updateSkillList index skillLevel u.positions }) model ! []

    ChangeDomainSelect str ->
      { model | selectedDomainOption = str } ! []

    ChangePositionSelect str ->
      { model | selectedPositionOption = str } ! []

    AddDomain ->
      updateUser (\u -> { u | domains = u.domains ++ [ Skill.Model model.selectedDomainOption Skill.Interested ] }) model ! []

    AddPosition ->
      updateUser (\u -> { u | positions = u.positions ++ [ Skill.Model model.selectedPositionOption Skill.Interested ] }) model ! []

    ChangePrimaryDomain str ->
      updateUser (\u -> { u | primaryDomain = str }) model ! []

    ChangePrimaryPosition str ->
      updateUser (\u -> { u | primaryPosition = str }) model ! []

    ChangeNickname str ->
      updateUser (\u -> { u | name = str }) model ! []

    ChangeDescription str ->
      updateUser (\u -> { u | description = str }) model ! []

    GetPositionOptions (Ok list) ->
      { model | positionOptions = list } ! []

    GetDomainOptions (Ok list) ->
      { model | domainOptions = list } ! []

    GetPositionOptions (Err _) ->
      model ! [] -- TODO error handling

    GetDomainOptions (Err _) ->
      model ! [] -- TODO error handling

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
                              , E.onInput ChangeNickname
                              ] []
                    else
                      H.text user.name
                  ]
              , H.p
                [ A.class "user-page__work-details" ]
                [ if model.editing
                  then H.select [ A.value user.primaryDomain
                                , E.on "change" (Json.map ChangePrimaryDomain E.targetValue)
                                ]
                    (H.option [A.value "Ei valittua toimialaa"] [ H.text "Valitse päätoimiala" ] :: List.map (\skill -> H.option [] [ H.text skill.heading ]) user.domains)
                  else H.text user.primaryDomain
                , H.br [] []
                , if model.editing
                  then H.select [ A.value user.primaryPosition
                                , E.on "change" (Json.map ChangePrimaryPosition E.targetValue)
                                ]
                    (H.option [A.value "Ei valittua tehtäväluokkaa"] [ H.text "Valitse päätehtäväluokka" ] :: List.map (\skill -> H.option [] [ H.text skill.heading ]) user.positions)
                  else H.text user.primaryPosition
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
                             , E.onInput ChangeDescription
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
      , H.div
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
