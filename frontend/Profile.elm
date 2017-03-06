module Profile exposing (..)

import Html as H
import Html.Attributes as A
import Html.Events as E
import Http
import Json.Decode as Json
import Json.Encode as JS
import Nav
import Skill
import State.Main as RootState
import State.Profile exposing (Model)
import User


type Msg
  = GetMe (Result Http.Error User.User)
  | Save User.User
  | Edit
  | AllowProfileCreation User.User
  | DomainSkillMessage Int Skill.Msg
  | PositionSkillMessage Int Skill.Msg
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
  | UpdateUser (Result Http.Error ())
  | UpdateConsent (Result Http.Error ())
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

updateMe : User.User -> Cmd Msg
updateMe user =
  put "/api/me" (User.encode user)
    |> Http.send UpdateUser

updateConsent : User.User -> Cmd Msg
updateConsent user =
  put "/api/me" (User.encode user)
    |> Http.send UpdateConsent

put : String -> JS.Value -> Http.Request ()
put url body =
  Http.request
    { method = "PUT"
    , headers = []
    , url = url
    , body = Http.jsonBody body
    , expect = Http.expectStringResponse (\_ -> Ok ())
    , timeout = Nothing
    , withCredentials = False
    }

updateSkillList : Int -> Skill.SkillLevel -> List Skill.Model -> List Skill.Model
updateSkillList index skillLevel list =
  List.indexedMap
    (\i x -> if i == index then Skill.update skillLevel x else x)
    list

deleteFromSkillList : Int -> List Skill.Model -> List Skill.Model
deleteFromSkillList index list =
  List.indexedMap (\i x -> if i == index then Nothing else Just x) list
    |> List.filterMap identity


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

    Save user ->
      model ! [ updateMe user ]

    AllowProfileCreation user ->
      let
        newUser = { user | profileCreated = True }
        newModel = { model
                     | user = Just newUser
                     , editing = True
                   }
      in
        newModel ! [ updateConsent newUser ]

    Edit ->
      { model | editing = True } ! []

    DomainSkillMessage index (Skill.LevelChange skillLevel) ->
      updateUser (\u -> { u | domains = updateSkillList index skillLevel u.domains }) model ! []

    PositionSkillMessage index (Skill.LevelChange skillLevel) ->
      updateUser (\u -> { u | positions = updateSkillList index skillLevel u.positions }) model ! []

    DomainSkillMessage index Skill.Delete ->
      updateUser (\u -> { u | domains = deleteFromSkillList index u.domains }) model ! []

    PositionSkillMessage index Skill.Delete ->
      updateUser (\u -> { u | positions = deleteFromSkillList index u.positions }) model ! []

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

    UpdateUser (Err _) ->
      model ! [] -- TODO error handling

    UpdateUser (Ok _) ->
      { model | editing = False } ! []

    UpdateConsent (Err _) ->
      model ! [] -- TODO error handling

    UpdateConsent (Ok _) ->
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
      case model.user of
        Just user ->
          H.button
            [ A.class "btn btn-primary profile__top-row-edit-button"
            , E.onClick <| if model.editing then Save user else Edit
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

viewUserMaybe : Model -> List (H.Html Msg)
viewUserMaybe model =
  model.user
    |> Maybe.map (viewUser model)
    |> Maybe.withDefault []


viewUser : Model -> User.User -> List (H.Html Msg)
viewUser model user =
  if not user.profileCreated
  then
    [ H.div
      [ A.class "splash-screen" ]
        [ H.div
          [ A.class "profile__consent-needed col-xs-12 col-md-5" ]
          [ H.h1 [] [ H.text "Tervetuloa Tradenomiittiin!" ]
          , H.p [] [ H.text "Tehdäksemme palvelun käytöstä mahdollisimman vaivatonta hyödynnämme Tradenomiliiton olemassa olevia jäsentietoja (nimesi, työhistoriasi). Luomalla profiilin hyväksyt tietojesi käytön Tradenomiitti-palvelussa. Voit muokata tietojasi myöhemmin." ]
          , H.button
            [ A.class "btn btn-lg profile__consent-btn-inverse"
            , E.onClick (AllowProfileCreation user)
            ]
            [ H.text "Luo profiili" ]
          ]
        ]
    ]
  else
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
