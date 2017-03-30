module Home exposing (..)

import Html as H
import Html.Attributes as A
import Link
import ListAds
import ListUsers
import Models.User exposing (User)
import Nav
import State.Home exposing (..)
import Util exposing (ViewMessage(..), UpdateMessage(..))

type Msg
  = ListAdsMessage ListAds.Msg
  | ListUsersMessage ListUsers.Msg
  | ClickCreateProfile


update : Msg -> Model -> (Model, Cmd (UpdateMessage Msg))
update msg model =
  case msg of
    ListAdsMessage msg ->
      let
        (listAdsModel, cmd) = ListAds.update msg model.listAds
      in
        { model | listAds = listAdsModel } ! [ Util.localMap ListAdsMessage cmd ]
    ListUsersMessage msg ->
      let
        (listUsersModel, cmd) = ListUsers.update msg model.listUsers
      in
        { model | listUsers = listUsersModel } ! [ Util.localMap ListUsersMessage cmd ]

    ClickCreateProfile ->
      { model | createProfileClicked = True } ! []

initTasks : Model -> Cmd (UpdateMessage Msg)
initTasks model =
  Cmd.batch
    [ Util.localMap ListAdsMessage (ListAds.initTasks model.listAds)
    , Util.localMap ListUsersMessage (ListUsers.initTasks model.listUsers)
    ]


view : Model -> Maybe User -> H.Html (ViewMessage Msg)
view model userMaybe =
  H.div
    []
    [ introScreen userMaybe
    , listLatestAds model
    , listUsers model
    , tradenomiittiSection
    ]

-- FIRST INFO SCREEN --

introScreen : Maybe User -> H.Html (ViewMessage Msg)
introScreen userMaybe =
  H.div
    [ A.class "home__intro-screen" ]
    (introAnimation :: introBoxes userMaybe)

introAnimation : H.Html msg
introAnimation =
  H.canvas [ A.id "home-intro-canvas"
           , A.class "home__intro-canvas"
           ] []

introBoxes : Maybe User -> List ( H.Html (ViewMessage Msg) )
introBoxes userMaybe =
  let
    createProfile =
      case userMaybe of
        Just _ ->
          []
        Nothing ->
          [ H.div
            [ A.class "home__introbox home__introbox--button-container col-sm-4 col-sm-offset-4" ]
            [ Link.button "Luo oma profiili" "home__introbox--button btn btn-primary"
                (Nav.LoginNeeded (Nav.Home |> Nav.routeToPath |> Just))
            ]
          ]
  in
    [ H.div
      [ A.class "home__introbox col-sm-6 col-sm-offset-3" ]
      [ H.h2
          [ A.class "home__introbox--heading" ]
          [ H.text "Kohtaa tradenomi" ]
      ]
    , H.div
      [ A.class "home__introbox col-sm-6 col-sm-offset-3" ]
      [ H.div
          [ A.class "home__introbox--content" ]
          [ H.text "Tradenomiitti on tradenomien oma kohtaamispaikka, jossa jäsenet löytävät toisensa yhteisten aiheiden ympäriltä ja hyötyvät toistensa kokemuksista." ]
      ]
    ] ++ createProfile

-- LIST LATEST ADS --

listLatestAds : Model -> H.Html (ViewMessage Msg)
listLatestAds model =
  H.div
    [ A.class "home__latest-ads" ]
    [ H.div
      [ A.class "home__section--container" ]
      [ listAdsHeading
      , listFourAds model
      ]
     ]

listAdsHeading : H.Html (ViewMessage Msg)
listAdsHeading =
  H.div
    [ A.class "home__section--heading row" ]
    [ sectionHeader "Uusimmat ilmoitukset"
    , listAdsButtons
    ]

listAdsButtons : H.Html (ViewMessage Msg)
listAdsButtons =
  H.div
    [ A.class "home__section--heading--buttons col-sm-7" ]
    [ Link.button
        "katso kaikki ilmoitukset"
        "home__section--heading--buttons--inverse btn btn-primary"
        Nav.ListAds
    , Link.button
        "jätä ilmoitus"
        "home__section--heading--buttons--normal btn btn-primary"
        Nav.CreateAd
    ]

sectionHeader : String -> H.Html msg
sectionHeader title =
  H.div
    [ A.class "home__section--heading--text col-sm-5" ]
    [ H.text title ]

listFourAds : Model -> H.Html (ViewMessage msg)
listFourAds model =
  H.div
    []
    (ListAds.viewAds (List.take 4 model.listAds.ads))

-- LIST USERS --

listUsers : Model -> H.Html (ViewMessage msg)
listUsers model =
  H.div
    [ A.class "home__list-users" ]
    [ H.div
      [ A.class "home__section--container" ]
      [ listUsersHeading
      , listThreeUsers model
      ]
     ]

listUsersHeading : H.Html (ViewMessage msg)
listUsersHeading =
  H.div
    [ A.class "home__section--heading row" ]
    [ sectionHeader "Löydä tradenomi"
    , listUsersButtons
    ]

listUsersButtons : H.Html (ViewMessage msg)
listUsersButtons =
  H.div
    [ A.class "home__section--heading--buttons col-sm-7" ]
    [ Link.button
        "katso kaikki tradenomit"
        "home__section--heading--buttons--inverse btn btn-primary"
        Nav.ListUsers
    , Link.button
        "muokkaa omaa profiilia"
        "home__section--heading--buttons--normal btn btn-primary"
        Nav.Profile
    ]

listThreeUsers : Model -> H.Html (ViewMessage msg)
listThreeUsers model =
  H.div
    [ A.class "row" ]
    (List.map ListUsers.viewUser (List.take 3 model.listUsers.users))

  -- TRADENOMIITTI AD --

tradenomiittiSection : H.Html (ViewMessage msg)
tradenomiittiSection =
  H.div
    [ A.class "home__tradenomiitti--background" ]
    [ H.div
        [ A.class "home__tradenomiitti--container" ]
        [ tradenomiittiRow ]
    ]
tradenomiittiRow : H.Html (ViewMessage msg)
tradenomiittiRow =
  H.div
    [ A.class "row"]
    [ H.div [ A.class "home__tradenomiitti--info-container  col-md-6" ] [ tradenomiittiInfo ]
    , tradenomiImage
    ]

tradenomiittiInfo : H.Html (ViewMessage msg)
tradenomiittiInfo =
  H.div
    [ A.class "home__tradenomiitti--info" ]
    [ tradenomiittiHeader
    , tradenomiittiInfoText
    , readMoreButton
    ]

tradenomiittiHeader : H.Html msg
tradenomiittiHeader =
  H.h2
    [ A.class "home__tradenomiitti--info--header" ]
    [ H.text "Lorem ipsum dolorem salet" ]

tradenomiittiInfoText : H.Html msg
tradenomiittiInfoText =
  H.p
    [ A.class "home__tradenomiitti--info--text" ]
    [ H.text "Tähän kuvaava teksti Tradenomiitistä. Hyötynäkökuma, eli mitä täällä voi tehdä ja miksi pitäisi liittyä. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua." ]

readMoreButton : H.Html (ViewMessage msg)
readMoreButton =
  Link.button
    "lue lisää"
    "home__tradenomiitti--info--read-more-button btn btn-primary"
    Nav.Info

tradenomiImage : H.Html msg
tradenomiImage =
  H.div
    [ A.class "col-md-6" ]
    [ H.img
      [ A.class "home__tradenomiitti--image"
      , A.src "/static/tral_person_image_square_1.jpg"
      ]
      []
    ]
