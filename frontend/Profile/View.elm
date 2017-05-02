module Profile.View exposing (..)

import Common
import Html as H
import Html.Attributes as A
import Html.Events as E
import Json.Decode as Json
import Link
import ListAds
import Models.User exposing (User)
import Nav
import Profile.Main exposing (Msg(..), BusinessCardField(..))
import Skill
import State.Config as Config
import State.Main as RootState
import State.Profile exposing (Model)
import SvgIcons
import Util exposing (ViewMessage(..))

view : Model -> RootState.Model -> H.Html (ViewMessage Msg)
view model rootState =
  case model.user of
    Just user ->
      if model.editing
        then editProfileView model user rootState
        else showProfileView model user rootState
    Nothing ->
      H.div [] []


editProfileView : Model -> User -> RootState.Model -> H.Html (ViewMessage Msg)
editProfileView model user rootState =
  H.div
    []
    [ Common.profileTopRow user model.editing Common.ProfileTab (saveOrEdit user model.editing)
    , editProfileHeading
    , membershipInfoEditing user
    , H.map LocalViewMessage (publicInfoEditing model user)
    , H.map LocalViewMessage (competences model rootState.config user)
    ]


saveOrEdit : User -> Bool -> H.Html (ViewMessage Msg)
saveOrEdit user editing =
  H.button
    [ A.class "btn btn-primary profile__top-row-edit-button"
    , E.onClick <| if editing then LocalViewMessage (Save user) else LocalViewMessage Edit
    , A.disabled <| user.name == ""
    , A.title <| if user.name == "" then "Kutsumanimi on pakollinen" else ""
    ]
    [ H.text (if editing then "Tallenna profiili" else "Muokkaa profiilia") ]

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
      [ A.class "container" ]
      [ H.div
          [ A.class "profile__editing--public-info row" ]
          [ publicInfo model user
          , businessCard user ]
      ]
    ]

publicInfo : Model -> User -> H.Html Msg
publicInfo model user =
  H.div
    [ A.class "col-sm-6 profile__editing--public-info--box" ]
    [ H.h3 [A.class "profile__editing--public-info--header"] [H.text "Julkiset tiedot" ]
    , H.p [A.class "profile__editing--public-info--text"] [H.text "Valitse itsellesi käyttäjänimi (yleisimmin etunimi) ja kuvaava titteli. Esittele itsesi ja osaamisesi muille kuvaavalla tekstillä"]
    , userInfoBoxEditing model user ]


businessCard : User -> H.Html Msg
businessCard user =
  H.div
    [ A.class "col-sm-6 profile__editing--public-info--box" ]
    [ H.h3 [A.class "profile__editing--public-info--header"] [H.text "käyntikortti" ]
    , H.p [A.class "profile__editing--public-info--text"] [ H.text "Täydennä alle tiedot, jotka haluat lähettää käyntikortin mukana. "
    , H.span [ A.class "profile__editing--bold" ] [ H.text "Tiedot näkyvät vain niille, joille olet lähettänyt kortin" ]
     ]
    , case user.businessCard of
        Just businessCard ->
          businessCardData user businessCard
        Nothing ->
          H.div [] [ H.text "Käyntikorttia ei löytynyt" ]
    ]

businessCardData : User -> Models.User.BusinessCard -> H.Html Msg
businessCardData user businessCard =
  H.div
    [ A.class "profile__business-card" ]
    [ H.div [ A.class "profile__business-card--container" ] [ H.div
      [ A.class "profile__business-card--data"]
      [ H.span [ A.class "user-page__pic" ] [ Common.picElementForUser user ]
      , H.div
          [ A.class "inline profile__business-card--data--name-work" ]
          [ H.h4  []
            [ H.input [ A.class "profile__business-card--name-work--input"
                      , A.placeholder "Koko nimi"
                      , A.value businessCard.name
                      , E.onInput (UpdateBusinessCard Profile.Main.Name)
                      ] []
            ]
          , H.h5 []
            [ H.input [ A.class "profile__business-card--name-work--input"
                      , A.placeholder "Titteli, Työpaikka"
                      , A.value businessCard.title
                      , E.onInput (UpdateBusinessCard Profile.Main.Title)
                      ] []
            ]
          ]
      ]
    , H.div [ A.class "profile__business-card--data--contact"]
        [ businessCardDataInput businessCard Location
        , businessCardDataInput businessCard Phone
        , businessCardDataInput businessCard Email
        , businessCardDataInput businessCard LinkedIn
        ]
      ]
    ]

businessCardView : User -> Models.User.BusinessCard -> H.Html (ViewMessage msg)
businessCardView user businessCard =
  H.div
    [ A.class "profile__business-card profile__business-card-view" ]
    [ H.div
      [ A.class "profile__business-card--container" ]
      [ H.a
        [ A.class "profile__business-card--data card-link"
        , Link.action (Nav.User user.id)
        ]
        [ H.span [ A.class "user-page__businesscard-view-pic" ] [ Common.picElementForUser user ]
        , H.div
            [ A.class "inline profile__business-card--data--name-work" ]
            [ H.h4  []
              [ H.text businessCard.name ]
            , H.h5 []
              [ H.text businessCard.title]
            ]
        ]
    , H.div [ A.class "profile__business-card--data--contact"]
        [ businessCardDataView businessCard Location
        , businessCardDataView businessCard Phone
        , businessCardDataView businessCard Email
        , businessCardDataView businessCard LinkedIn
        ]
      ]
    ]


businessCardDataInput : Models.User.BusinessCard -> BusinessCardField -> H.Html Msg
businessCardDataInput card field =
  let
    value =
      case field of
        Name -> card.name
        Title -> card.title
        Location -> card.location
        Phone -> card.phone
        Email -> card.email
        LinkedIn -> card.linkedin
    icon =
      case field of
        Location -> [ SvgIcons.location ]
        Phone -> [ SvgIcons.phone ]
        Email -> [ SvgIcons.email ]
        LinkedIn -> [ H.i [ A.class "fa fa-linkedin" ] [] ]
        _ -> []
    class =
      A.classList
        [ ("profile__business-card--input", True)
        , ("profile__business-card--input--empty", value == "")
        , ("profile__business-card--input--filled", value /= "")
        ]
  in
    H.p
      [ class ]
      [ H.span [ class , A.class "profile__business-card--input-icon" ] icon
      , H.input
          [ A.placeholder <| fieldToString field
          , A.value value
          , E.onInput (UpdateBusinessCard field)
          ] []
      , H.hr [ A.class "profile__business-card--input-line", class ] []
      ]

businessCardDataView : Models.User.BusinessCard -> BusinessCardField -> H.Html msg
businessCardDataView card field =
  let
    value =
      case field of
        Name -> card.name
        Title -> card.title
        Location -> card.location
        Phone -> card.phone
        Email -> card.email
        LinkedIn -> card.linkedin
    icon =
      case field of
        Location -> [ SvgIcons.location ]
        Phone -> [ SvgIcons.phone ]
        Email -> [ SvgIcons.email ]
        LinkedIn -> [ H.i [ A.class "fa fa-linkedin" ] [] ]
        _ -> []
    class =
      A.classList
        [ ("profile__business-card--input", True)
        , ("profile__business-card--input--filled", value /= "")
        ]
  in
    if String.length value > 0
    then
      H.p
        [ class ]
        [ H.span [ class , A.class "profile__business-card--input-icon" ] icon
        , H.span [] [H.text value]
        , H.hr [ A.class "profile__business-card--input-line", class ] []
        ]
    else
      H.span [] []


fieldToString : BusinessCardField -> String
fieldToString field =
  case field of
    Name -> "Koko nimi"
    Title -> "Titteli, Työpaikka"
    Location -> "Paikkakunta"
    Phone -> "Puhelinnumero"
    Email -> "Sähköposti"
    LinkedIn -> "LinkedIn-linkki"


showProfileView : Model -> User -> RootState.Model ->  H.Html (ViewMessage Msg)
showProfileView model user rootState =
  H.div [ A.class "user-page" ] <|
    [ Common.profileTopRow user model.editing Common.ProfileTab (saveOrEdit user model.editing)
    ] ++ (viewUserMaybe model True rootState.config)


competences : Model -> Config.Model -> User -> H.Html Msg
competences model config user =
  H.div
    [ A.class "container-fluid profile__editing--competences" ]
    [ H.div
      [ A.class "container"
      ]
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
          (userExpertise model user config)
      ]
    ]

userExpertise : Model -> User -> Config.Model -> List (H.Html Msg)
userExpertise model user config =
  [ userDomains model user config
  , userPositions model user config
  , userSkills model user config
  ]

viewUserMaybe : Model -> Bool -> Config.Model -> List (H.Html (ViewMessage Msg))
viewUserMaybe model ownProfile config =
  model.user
    |> Maybe.map (viewUser model ownProfile (H.div [] []) config)
    |> Maybe.withDefault
      [ H.div
        [ A.class "container"]
          [ H.div [ A.class "row user-page__section" ]
            [ H.text "Et ole kirjautunut" ]
          ]
      ]


viewUser : Model -> Bool -> H.Html (ViewMessage Msg) -> Config.Model -> User -> List (H.Html (ViewMessage Msg))
viewUser model ownProfile contactUser config user =
  let
    viewAds = ListAds.viewAds <| if model.viewAllAds then model.ads else List.take 2 model.ads
    showMoreAds =
      -- if we are seeing all ads, don't show button
      -- if we don't have anything more to show, don't show button
      if model.viewAllAds || List.length model.ads <= 2
      then []
      else
        [ H.button
          [ A.class "btn user-page__activity-show-more"
          , E.onClick <| LocalViewMessage ShowAll
          ]
          [ H.span [] [ H.text "Näytä kaikki aktiivisuus" ]
          , H.i [ A.class "fa fa-chevron-down" ] []
          ]
        ]
  in
    [ H.div
      [ A.class "container" ]
      [ H.div
        [ A.class "row user-page__section user-page__first-block" ]
        [ H.map LocalViewMessage (userInfoBox model user)
        , if ownProfile
            then H.map LocalViewMessage (editProfileBox user)
            else contactUser
        ]
      ]
    , H.div
      [ A.class "user-page__activity" ]
      [ H.div
        [ A.class "container" ] <|
        [ H.div
          [ A.class "row" ]
          [ H.div
            [ A.class "col-sm-12" ]
            [ H.h3 [ A.class "user-page__activity-header" ] [ H.text "Aktiivisuus" ]
            ]
          ]
        ] ++ viewAds
          ++ showMoreAds
      ]
    , H.div
      [ A.class "container" ]
      [ H.div
        [ A.class "row" ] <|
          List.map (H.map LocalViewMessage) (userExpertise model user config)
      ]
    ]

editProfileBox : User -> H.Html Msg
editProfileBox user =
  H.div
    [ A.class "col-md-6 user-page__edit-or-contact-user"]
    [ H.p [] [ H.text ("Onhan profiilisi ajan tasalla? Mielenkiintoinen ja aktiivinen profiili auttaa luomaan kontakteja") ]
    , H.button
            [ A.class "btn btn-primary profile__edit-button"
            , E.onClick Edit
            ]
            [ H.text  "Muokkaa profiilia" ]
    ]


userInfoBoxEditing2 : Model -> User -> List (H.Html Msg)
userInfoBoxEditing2 model user =
  [ H.div
    [ A.class "user-page__pic-container" ]
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
  , H.div
    [ A.class "user-page__editing-name-details" ]
    [ H.h4 [ A.class "user-page__name" ]
      [
            H.input
              [ A.placeholder "Miksi kutsumme sinua?"
              , A.value user.name
              , E.onInput ChangeNickname
              ] []
        ]
    , H.p
      [ A.class "user-page__work-details" ]
      [
          H.input
          [ A.value user.title
          , E.onInput ChangeTitle
          , A.placeholder "Titteli"
          ]
          []
      ]
    , location model user
    ]
  ]


userInfoBoxEditing : Model -> User -> H.Html Msg
userInfoBoxEditing model user =
  H.div
    []
    [ H.div
      [ A.class "row" ]
      [ H.div
        [ A.class "col-xs-12 user-page__editing-pic-and-name" ]
          (userInfoBoxEditing2 model user)
      ]
    , userDescription model user
    ]

userInfoBox : Model -> User -> H.Html Msg
userInfoBox model user =
  H.div
    [ A.class "col-md-6 user-page__user-info-box" ]
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
                [ A.value user.title
                , E.on "change" (Json.map ChangeTitle E.targetValue)
                ]
                []
              else H.text user.title
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
  H.div
    [ A.classList
      [ ("profile__location", True)
      , ("user-page__editing-location", model.editing)
      ]
    ]
    [ H.img [ A.class "profile__location--marker", A.src "/static/lokaatio.svg" ] []
    , if model.editing
        then
          locationSelect user
        else
          H.span [A.class "profile__location--text"] [ H.text (user.location) ]
    ]


optionPreselected : String -> String -> H.Html msg
optionPreselected default value =
  if default == value
    then H.option [ A.selected True ] [ H.text value ]
    else H.option [] [ H.text value ]


userDomains : Model -> User -> Config.Model ->  H.Html Msg
userDomains model user config =
  H.div
    [ A.class "col-xs-12 col-sm-6 col-md-4 last-row"
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
        [ select config.domainOptions ChangeDomainSelect "Valitse toimiala" "Lisää toimiala, josta olet kiinnostunut tai sinulla on osaamista"
        ]
     else [])
    )

userSkills : Model -> User -> Config.Model -> H.Html Msg
userSkills model user config =
  H.div
    [ A.class "col-xs-12 col-sm-6 col-md-4 last-row"
    ] <|
    [ H.h3 [ A.class "user-page__competences-header" ] [ H.text "Osaaminen" ]
    ] ++
        (if model.editing
          then [ H.p [ A.class "profile__editing--competences--text"] [H.text "Mitä taitoja sinulla on?" ] ]
          else [ H.p [ A.class "profile__editing--competences--text"] [] ])
       ++ (List.map
            (\rowItems ->
               H.div
               [ A.class "row user-page__competences-special-skills-row" ]
               (List.map
                  (\skill ->
                     H.div
                     [ A.class "user-page__competences-special-skills col-xs-6" ] <|
                     [ H.span
                       [ A.class "user-page__competences-special-skills-text"]
                       [ H.text skill ]
                     ] ++ if model.editing then [ H.i
                       [ A.class "fa fa-remove user-page__competences-special-skills-delete"
                       , E.onClick (DeleteSkill skill)
                       ] []
                     ] else []
                  ) rowItems)
            ) (Common.chunk2 user.skills)
         ) ++
     (if model.editing then [ H.div
       []
       [ H.label
         [ A.class "user-page__competence-select-label" ]
         [ H.text "Lisää taito" ]
       , H.span
         [ A.class "user-page__competence-select-container" ]
         [ H.input
           [ A.type_ "text"
           , A.id "skills-input"
           , A.class "user-page__competence-select"
           , A.placeholder "Valitse taito"
           ] []
         ]
       ]
     ] else [])


userPositions : Model -> User -> Config.Model -> H.Html Msg
userPositions model user config =
  H.div
    [ A.class "col-xs-12 col-sm-6 col-md-4 last-row"
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
            [ select config.positionOptions ChangePositionSelect "Valitse tehtäväluokka" "Lisää tehtäväluokka, josta olet kiinnostunut tai sinulla on osaamista"
            ]
          else [])
    )

locationSelect : User -> H.Html Msg
locationSelect user =
  H.span
    [ A.class "user-page__location-select-container" ]
    [ H.select
      [ E.on "change" (Json.map ChangeLocation E.targetValue)
      , A.class "user-page__location-select"
      ]
      (List.map (optionPreselected user.location) ("" :: Config.finnishRegions))
    ]

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

tralInfo : Models.User.Extra -> H.Html msg
tralInfo extra =
  let
    row title value =
      H.tr []
        [ H.td [] [ H.text title ]
        , H.td [] [ H.text value ]
        ]
  in
    H.table
      [ A.class "user-page__membership-info-definitions" ]
      [ row "Kutsumanimi" extra.nick_name
      , row "Etunimi" extra.first_name
      , row "Sukunimi" extra.last_name
      , row "Tehtäväluokat" (String.join ", " extra.positions)
      , row "Toimiala" (String.join ", " extra.domains)
      , row "Sähköposti" extra.email
      , row "Matkapuhelinnumero" extra.phone
      , row "Maakunta" extra.geoArea
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

