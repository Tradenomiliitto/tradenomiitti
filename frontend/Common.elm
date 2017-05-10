module Common exposing (..)

import Html as H
import Html.Attributes as A
import Html.Events as E
import Json.Decode as Json
import Link
import Models.User exposing (User)
import Nav exposing (Route, routeToPath, routeToString)
import SvgIcons
import Util exposing (ViewMessage(..))

type ProfileTab = SettingsTab | ProfileTab | ContactsTab

profileTopRow : User -> Bool -> ProfileTab -> H.Html (ViewMessage msg) -> H.Html (ViewMessage msg)
profileTopRow user editing profileTab saveOrEdit =
  let
    logoutLink =
      H.a
        [ A.href "/uloskirjautuminen"
        , A.classList
          [ ("btn", True)
          , ("profile__top-row-tab-button--hidden"
            , editing )
          ]
        ]
        [ H.text "Kirjaudu ulos" ]
    tabToNav tab =
      case tab of
        ProfileTab -> Nav.Profile
        SettingsTab -> Nav.Settings
        ContactsTab -> Nav.Contacts

    tabToText tab =
      case tab of
        ProfileTab -> "Oma profiili"
        SettingsTab -> "Asetukset"
        ContactsTab -> "Käyntikortit"

    button tab =
      H.h5
        ([ A.classList
            [ ("profile__top-row-tab-button", True)
            , ("profile__top-row-tab-button--active", tab == profileTab)
            , ("profile__top-row-tab-button--white"
              , profileTab == ProfileTab && editing)
            , ("profile__top-row-tab-button--hidden"
              , tab /= ProfileTab && editing)
            ]
        ] ++ if tab /= profileTab then [ E.onClick << Link << tabToNav <| tab] else [])
        [ H.text << tabToText <| tab ]
    profileButton =
      button ProfileTab
    settingsButton =
      button SettingsTab
    contactsButton =
      button ContactsTab
  in
    H.div
      [ A.classList
          [ ("profile__top-row", True)
          , ("profile__top-row--editing", editing)
          ]
      ]
      [ H.div
        [ A.class "container" ]
        [ H.div
          [ A.class "row profile__top-row-content-row" ]
          [ H.div
            [ A.class "col-sm-6 col-xs-12" ]
            [ profileButton
            , contactsButton
            , settingsButton
            ]

          , H.div
            [ A.class "col-sm-6 col-xs-12 profile__buttons" ]
            [ saveOrEdit
            , logoutLink
            ]
          ]
        ]
      ]


authorInfo : User -> H.Html (ViewMessage msg)
authorInfo user =
  H.a
    [ Link.action (Nav.User user.id)
    , A.href (Nav.routeToPath (Nav.User user.id))
    ]
    [ H.div
      []
      [ H.span [ A.class "author-info__pic" ] [ picElementForUser user ]
      , H.span
        [ A.class "author-info__info" ]
        [ H.span [ A.class "author-info__name"] [ H.text user.name ]
        , H.br [] []
        , H.span [ A.class "author-info__title"] [ H.text user.title ]
        ]
      ]
    ]

picElementForUser : User -> H.Html msg
picElementForUser user =
  user.croppedPictureFileName
    |> Maybe.map (\url ->
                   H.img
                     [ A.src <| "/static/images/" ++ url
                     ]
                     []
                )
    |> Maybe.withDefault
      SvgIcons.userPicPlaceHolder

authorInfoWithLocation : User -> H.Html (ViewMessage msg)
authorInfoWithLocation user =
  H.a
    [ Link.action (Nav.User user.id)
    , A.href (Nav.routeToPath (Nav.User user.id))
    ]
    [ H.div
      []
      [ H.span [ A.class "author-info__pic" ] [ picElementForUser user ]
      , H.span
        [ A.class "author-info__info" ]
        [ H.span [ A.class "author-info__name"] [ H.text user.name ]
        , H.br [] []
        , H.span [ A.class "author-info__title"] [ H.text user.title ]
        , H.br [] []
        , showLocation user.location
        ]
      ]
    ]

link : Route -> (Route -> msg ) -> H.Html msg
link route toMsg =
  let
    action = linkAction route toMsg
  in
    H.a
      [ action
      , A.href (routeToPath route)
      ]
      [ H.text (routeToString route) ]


linkAction : Route -> (Route -> msg) -> H.Attribute msg
linkAction route toMsg =
  E.onWithOptions
    "click"
    { stopPropagation = False
    , preventDefault = True
    }
    (Json.succeed <| toMsg route)

showLocation : String -> H.Html msg
showLocation location =
  H.div [ A.class "profile__location" ]
    [ H.img [ A.class "profile__location--marker", A.src "/static/lokaatio.svg" ] []
    , H.span [ A.class "profile__location--text" ] [ H.text (location) ]
    ]

lengthHint : String -> String -> Int -> Int -> H.Html msg
lengthHint class text minLength maxLength =
  H.span
    [ A.class class ]
    [ H.text <|
      if String.length text < minLength
      then
        "Vielä vähintään " ++ toString (minLength - String.length text) ++ " merkkiä"
      else
        if String.length text <= maxLength
        then
          "Enää korkeintaan " ++ toString (maxLength - String.length text) ++ " merkkiä"
        else
          toString (String.length text - maxLength) ++ " merkkiä liian pitkä"
    ]

type Filter = Domain | Position | Location
prompt : Filter -> String
prompt filter =
  case filter of
    Domain -> "Valitse toimiala"
    Position -> "Valitse tehtäväluokka"
    Location -> "Valitse maakunta"


select
     : String
     -> (Maybe String -> msg)
     -> Filter
     -> List String
     -> { a
         | selectedDomain : Maybe String
         , selectedLocation : Maybe String
         , selectedPosition : Maybe String
       }
     -> H.Html msg
select class toMsg filter options model =
  let
    isSelected option filter =
      case filter of
        Domain ->
          Just option == model.selectedDomain
        Position ->
          Just option == model.selectedPosition
        Location ->
          Just option == model.selectedLocation
  in
    H.span
      [ A.class <| class ++ "__select-container" ]
      [ H.select
        [ A.class <| class ++ "__select"
        , E.on "change"
          (E.targetValue
              |> Json.map
                (\str ->
                  if str == prompt filter
                  then Nothing
                  else Just str
                )
              |> Json.map toMsg
          )
        ] <|
        List.map
            (\o ->
              H.option
                [ A.selected (isSelected o filter)]
                [ H.text o])
            (prompt filter :: options)
      ]


typeaheadInput : String -> String -> String -> H.Html msg
typeaheadInput classPrefix placeholder id =
  H.div
    []
    [ H.span
      [ A.classList
          [ (classPrefix ++ "select-container", True)
          , (classPrefix ++ "input", True)
          ]
      ]
      [ H.input
        [ A.type_ "text"
        , A.id id
        , A.class <| classPrefix ++ "select"
        , A.placeholder placeholder
        ] []
      ]
    ]

{--
   don't ask for more when
     * we are not getting any more
     * footer is visible only because we are doing initial render and possibly scrolling up
        -> wait atleast until we have gotten the first reply before asking for more
-}
shouldNotGetMoreOnFooter : List a -> Int -> Bool
shouldNotGetMoreOnFooter list cursor =
  cursor > List.length list || cursor == 0


chunk2 : List a -> List (List a)
chunk2 = List.reverse << List.foldl rowFolder []

-- transforms a list to a list of lists of two elements: [1, 2, 3, 4, 5] => [[5], [3, 4], [1, 2]]
-- note: reverse the results if you need the elements to be in original order
rowFolder : a -> List (List a) -> List (List a)
rowFolder x acc =
  case acc of
    [] -> [[x]]
    row :: rows ->
      case row of
        el1 :: el2 :: els -> [x] :: row :: rows
        el :: els -> [el, x] :: rows
        els -> (x :: els) :: rows

chunk3 : List a -> List (List a)
chunk3 = List.reverse << List.foldl rowFolder3 []

-- transforms a list to a list of lists of three elements: [1, 2, 3, 4, 5] => [[4, 5], [1, 2, 3]]
-- note: reverse the results if you need the elements to be in original order
rowFolder3 : a -> List (List a) -> List (List a)
rowFolder3 x acc =
  case acc of
    [] -> [[x]]
    row :: rows ->
      case row of
        el1 :: el2 :: el3 :: els -> [x] :: row :: rows
        el1 :: el2 :: els -> [el1, el2, x] :: rows
        el1 :: els -> [el1, x] :: rows
        els -> ([x]) :: rows
