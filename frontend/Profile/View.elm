module Profile.View exposing (..)

import Common
import Html as H
import Html.Attributes as A
import Html.Events as E
import Json.Decode as Json
import Util exposing (ViewMessage(..))
import ListAds
import Models.User exposing (User)
import Nav
import Profile.Main exposing (Msg(..))
import Skill
import State.Main as RootState
import State.Profile exposing (Model)
import SvgIcons

view : Model -> RootState.Model -> H.Html (ViewMessage Msg)
view model rootState =
  if model.editing
    then editProfileView model rootState
    else showProfileView model rootState


editProfileView : Model -> RootState.Model -> H.Html (ViewMessage Msg)
editProfileView model rootState =
  case model.user of
    Just user ->
      H.div
        []
        [ profileTopRow model rootState
        , editProfileHeading
        , membershipInfoEditing user
        , H.map LocalViewMessage (publicInfoEditing model user)
        , H.map LocalViewMessage (competences model user)
        ]
    Nothing -> H.div [] []



editProfileHeading : H.Html msg
editProfileHeading =
  H.div [ A.class "container" ] [
    H.div [ A.class "row"] [
  H.div
    [ A.class "profile__editing--heading col-sm-6 col-sm-offset-3" ]
    [ H.h2 [ A.class "profile__editing--heading--title" ] [ H.text "Muokkaa profiilia" ]
    , H.p [ A.class "profile__editing--heading--content" ] [ H.text "Tehdäksemme Tradenomiitin käytöstä sinulle mahdollisimman vaivatonta, olemme luoneet sinulle profiilin TRAL:n jäsentietojen perusteella. Viimeistele profiilisi tarkastamalla jäsentietosi, muokkaamalla julkista profiiliasi ja täyttämällä henkilökohtainen käyntikorttisi."]
    ]
  ]
  ]

membershipInfoEditing : User -> H.Html msg
membershipInfoEditing user =
  H.div
    [ A.class "profile__editing--membership container" ]
      [ H.div
        [ A.class "row"]
        [ membershipDataBoxEditing user
        , membershipDataInfo
        ]
      ]


membershipDataInfo : H.Html msg
membershipDataInfo =
   H.div
        [ A.class "profile__editing--membership--info col-md-6" ]
        [
          H.p
            [ A.class "profile__editing--membership--info--text" ]
            [ H.text "Profiilissa hyödynnetään liiton jäsentietoja. Tarkistathan, että tietosi ovat järjestelmässämme ajan tasalla. "
            , H.span [ A.class "profile__editing--bold" ] [H.text "Jäsentiedot eivät näy sellaisenaan muille."
             ]
            ]
        , H.a
          [ A.href "https://asiointi.tral.fi"
          , A.target "_blank"
          ]
          [ H.button
            [ A.class "profile__editing--membership--info--button btn btn-primary" ]
            [ H.text "päivitä jäsentiedot"
            ]
          ]
        ]



publicInfoEditing : Model -> User -> H.Html Msg
publicInfoEditing model user =
  H.div
    [ A.class "container-fluid" ]
    [ H.div
        [ A.class "profile__editing--public-info row" ]
        [ publicInfo model user
        , businessCard ]
    ]

publicInfo : Model -> User -> H.Html Msg
publicInfo model user =
  H.div
    [ A.class "col-sm-6 profile__editing--public-info--box" ]
    [ H.h3 [A.class "profile__editing--public-info--header"] [H.text "Julkiset tiedot" ]
    , H.p [A.class "profile__editing--public-info--text"] [H.text "Valitse itsellesi käyttäjänimi (yleisimmin etunimi) ja kuvaava titteli. Esittele itsesi ja osaamisesi muille kuvaavalla tekstillä"]
    , userInfoBoxEditing model user ]


businessCard : H.Html msg
businessCard =
  H.div
    [ A.class "col-sm-6 profile__editing--public-info--box" ]
    [ H.h3 [A.class "profile__editing--public-info--header"] [H.text "käyntikortti" ]
    , H.p [A.class "profile__editing--public-info--text"] [ H.text "Täydennä alle tiedot, jotka haluat lähettää käyntikortin mukana. "
    , H.span [ A.class "profile__editing--bold" ] [ H.text "Tiedot näkyvät vain niille, joille olet lähettänyt kortin" ]
     ]
    ]

showProfileView : Model -> RootState.Model ->  H.Html (ViewMessage Msg)
showProfileView model rootState =
  H.div [ A.class "user-page" ] <|
    [ profileTopRow model rootState
    ] ++ (viewUserMaybe model)


competences : Model -> User -> H.Html Msg
competences model user =
  H.div
    [ A.class "container profile__editing--competences" ]
    [ H.div [ A.class "profile__editing--competences--row row" ]
        [
          H.div
            [ A.class "profile__editing--competences--heading col-md-7" ]
            [ H.h3
            [ A.class "profile__editing--competences--heading--title" ]
            [ H.text "Muokkaa osaamistasi" ]
        , H.p
            [ A.class "profile__editing--competences--heading--text" ]
            [ H.text "Osaamisesi on esitäytetty jäsentietojemme perusteella. Muokkaa ja täydennä tehtäviä ja toimialoja, jotta Tradenomiitti voi palvella sinua paremmin ja jotta muut tradenomit löytäisivät sinut helpommin. "
            , H.span [A.class "profile__editing--bold"] [ H.text "Osaaminen näkyy kaikille käyttäjille." ]
            ]
        ]
    ]
    , H.div
        [ A.class "profile__editing--competences--row row" ]
        [ userDomains model user
        , userPositions model user
        ]
    ]


profileTopRow : Model -> RootState.Model -> H.Html (ViewMessage Msg)
profileTopRow model rootState =
  let
    logonLink =
      case model.user of
        Just _ ->
          H.a
            [ A.href "/uloskirjautuminen"
            , A.class "btn"
            ]
            [ H.text "Kirjaudu ulos" ]
        Nothing ->
          H.a
            [ A.href <| Nav.ssoUrl rootState.rootUrl (Nav.routeToPath Nav.Profile |> Just)
            , A.class "btn"
            ]
            [ H.text "Kirjaudu sisään" ]

    saveOrEdit =
      case model.user of
        Just user ->
          H.button
            [ A.class "btn btn-primary profile__top-row-edit-button"
            , E.onClick <| if model.editing then LocalViewMessage (Save user) else LocalViewMessage Edit
            ]
            [ H.text (if model.editing then "Tallenna profiili" else "Muokkaa profiilia") ]
        Nothing ->
          H.div [] []

    settingsButton =
      H.button
        [ A.class "btn btn-default profile__top-row-settings-button"
        , E.onClick (Link Nav.Settings)
        ]
        [ H.text "Asetukset" ]
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
            [ settingsButton
            , saveOrEdit
            , logonLink
            ]
          ]
        ]
      ]

viewUserMaybe : Model -> List (H.Html (ViewMessage Msg))
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


viewUser : Model -> User -> List (H.Html (ViewMessage Msg))
viewUser model user =
  [ H.div
    [ A.class "container" ]
    [ H.div
      [ A.class "row user-page__section" ]
      [ H.map LocalViewMessage (userInfoBox model user)
      , H.map LocalViewMessage (membershipDataBox user)
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
      [ H.map LocalViewMessage (userDomains model user)
      , H.map LocalViewMessage (userPositions model user)
      ]
    ]
  ]


userInfoBoxEditing2 : Model -> User -> H.Html Msg
userInfoBoxEditing2 model user =
  H.div
    [A.class "container"]
    [ H.div
        [A.class "row"]
        [ H.div
          [ A.class "user-page__pic-container col-md-1" ]
          [ H.span
            [ A.class "user-page__pic"
            , E.onClick (ChangeImage user)
            , E.onMouseEnter MouseEnterProfilePic
            , E.onMouseLeave MouseLeaveProfilePic
            ]
            [ if model.mouseOverUserImage
              then
                SvgIcons.upload
              else
                Common.picElementForUser user
            ]
          ]
        , H.div [A.class "col-md-4" ]
          [ H.h4 [ A.class "user-page__name" ]
            [
                  H.input [ A.placeholder "Miksi kutsumme sinua?"
                  , A.value user.name
                  , E.onInput ChangeNickname
                  ] []
              ]
          , H.p
            [ A.class "user-page__work-details" ]
            [
                H.input
                [ A.value user.primaryPosition
                , E.onInput ChangeTitle
                ]
                []
            ]
          , location model user
          ]
      ]
    ]


userInfoBoxEditing : Model -> User -> H.Html Msg
userInfoBoxEditing model user =
  H.div
    [ A.class "col-md-6" ]
    [ H.div
      [ A.class "row" ]
      [ userInfoBoxEditing2 model user
      ]
    , userDescription model user
    ]

userInfoBox : Model -> User -> H.Html Msg
userInfoBox model user =
  H.div
    []
    [ H.div
      [ A.class "row" ]
      [ H.div
         [ A.class "col-xs-12"]
         [ H.div
            [ A.class "pull-left user-page__pic-container" ]
            [ H.span [ A.class "user-page__pic" ] [ Common.picElementForUser user ] ]
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
          , location model user
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

location : Model -> User -> H.Html Msg
location model user =
  H.div [ A.class "profile__location" ]
    [ H.img [ A.class "profile__location--marker", A.src "/static/lokaatio.svg" ] []
    , if model.editing
        then
          H.select
            [ E.on "change" (Json.map ChangeLocation E.targetValue) ]
            (List.map (optionPreselected user.location) finnishRegions)
        else
          H.span [A.class "profile__location--text"] [ H.text (user.location) ]
    ]


optionPreselected : String -> String -> H.Html msg
optionPreselected default value =
  if default == value
    then H.option [ A.selected True ] [ H.text value ]
    else H.option [] [ H.text value ]


userDomains : Model -> User -> H.Html Msg
userDomains model user =
  H.div
    [ A.class "col-xs-12 col-sm-6"
    ]
    ([ H.h3 [ A.class "user-page__competences-header" ] [ H.text "Toimiala" ]
    ] ++
      (if model.editing
        then [ H.p [A.class "profile__editing--competences--text" ] [H.text "Valitse toimialat, joista olet kiinnostunut tai sinulla on kokemusta" ] ]
        else [ H.p [ A.class "profile__editing--competences--text" ] [] ])
     ++
      (List.indexedMap
        (\i x -> H.map (DomainSkillMessage i) <|
          Skill.view model.editing x)
            user.domains
    ) ++
    (if model.editing
      then
        [ select model.domainOptions ChangeDomainSelect "Valitse toimiala" "Lisää toimiala, josta olet kiinnostunut tai sinulla on osaamista"
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
        (if model.editing
          then [ H.p [ A.class "profile__editing--competences--text"] [H.text "Missä tehtävissä olet toiminut tai haluaisit toimia?" ] ]
          else [ H.p [ A.class "profile__editing--competences--text"] [] ])
       ++
        (List.indexedMap
          (\i x -> H.map (PositionSkillMessage i) <| Skill.view model.editing x)
          user.positions
        ) ++
        (if model.editing
          then
            [ select model.positionOptions ChangePositionSelect "Valitse tehtäväluokka" "Lisää tehtäväluokka, josta olet kiinnostunut tai sinulla on osaamista"
            ]
          else [])
    )

select : List String -> (String -> msg) -> String -> String -> H.Html msg
select options toEvent defaultOption heading =
  H.div
    []
    [ H.label
      [ A.class "user-page__competence-select-label" ]
      [ H.text heading ]
    , H.span
      [ A.class "user-page__competence-select-container" ]
      [ H.select
        [ E.on "change" (Json.map toEvent E.targetValue)
        , A.class "user-page__competence-select"
        ] <|
          H.option [] [ H.text defaultOption ] :: List.map (\o -> H.option [] [ H.text o ]) options
      ]
    ]

membershipDataBox : User -> H.Html msg
membershipDataBox user =
  case user.extra of
    Just extra ->
      H.div
        [ A.class "col-md-6 user-page__membership-info" ]
        [ H.h3 [ A.class "user-page__membership-info-heading" ] [ H.text "Jäsentiedot:" ]
        , H.span [] [ H.text "(eivät näy muille)"]
        , tralInfo extra
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

tralInfo : Models.User.Extra -> H.Html msg
tralInfo extra =
  H.table
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


membershipDataBoxEditing : User -> H.Html msg
membershipDataBoxEditing user =
  case user.extra of
    Just extra ->
      H.div
        [ A.class "col-md-6 profile__editing--membership--databox" ]
        [ H.h3 [ A.class "profile__editing--membership--databox--heading" ] [ H.text "TRAL:n  Jäsentiedot" ]
        , tralInfo extra
        ]
    Nothing ->
      H.div
        [ A.class "user-page__membership-info" ]
        [ H.h3 [ A.class "user-page__membership-info-heading" ] [ H.text "Jäsentiedot puuttuvat" ]
        ]

finnishRegions : List String
finnishRegions =
  [ ""
  , "Lappi"
  , "Pohjois-Pohjanmaa"
  , "Kainuu"
  , "Pohjois-Karjala"
  , "Pohjois-Savo"
  , "Etelä-Savo"
  , "Etelä-Karjala"
  , "Keski-Suomi"
  , "Etelä-Pohjanmaa"
  , "Pohjanmaa"
  , "Keski-Pohjanmaa"
  , "Pirkanmaa"
  , "Satakunta"
  , "Päijät-Häme"
  , "Kanta-Häme"
  , "Kymenlaakso"
  , "Uusimaa"
  , "Varsinais-Suomi"
  , "Ahvenanmaa"
  ]
