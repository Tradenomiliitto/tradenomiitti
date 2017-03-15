module Home exposing (..)

import Html as H
import Html.Attributes as A
import ListAds
import ListUsers
import State.Home exposing (..)

type Msg = ListAdsMessage ListAds.Msg | ListUsersMessage ListUsers.Msg


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    ListAdsMessage msg ->
      let
        (listAdsModel, cmd) = ListAds.update msg model.listAds
      in
        { model | listAds = listAdsModel } ! [ Cmd.map ListAdsMessage cmd ]
    ListUsersMessage msg ->
      let
        (listUsersModel, cmd) = ListUsers.update msg model.listUsers
      in
        { model | listUsers = listUsersModel } ! [ Cmd.map ListUsersMessage cmd ]

initTasks : Cmd Msg
initTasks = Cmd.batch [ Cmd.map ListAdsMessage ListAds.getAds, Cmd.map ListUsersMessage ListUsers.getUsers ]


view : Model -> H.Html Msg
view model =
  H.div
    []
    [ introScreen
    , listLatestAds model
    , listUsers model
    , tradenomiittiSection
    ]

-- FIRST INFO SCREEN --

introScreen : H.Html msg
introScreen =
  H.div
    [ A.class "home__intro-screen" ]
    (introAnimation :: introBoxes)

introAnimation : H.Html msg
introAnimation =
  H.canvas [ A.id "home-intro-canvas"
           , A.class "home__intro-canvas"
           ] []

introBoxes : List ( H.Html msg )
introBoxes =
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
  , H.div
    [ A.class "home__introbox home__introbox--button-container col-sm-4 col-sm-offset-4" ]
    [ H.button
        [ A.class "home__introbox--button btn btn-primary" ]
        [ H.text "luo oma profiili" ]
    ]
 ]

-- LIST LATEST ADS --

listLatestAds : Model -> H.Html Msg
listLatestAds model =
  H.div
    [ A.class "home__latest-ads" ]
    [ H.div
      [ A.class "home__section--container" ]
      [ listAdsHeading
      , listFourAds model
      ]
     ]

listAdsHeading : H.Html Msg
listAdsHeading =
  H.div
    [ A.class "home__section--heading row" ]
    [ sectionHeader "Uusimmat ilmoitukset"
    , listAdsButtons
    ]

listAdsButtons : H.Html Msg
listAdsButtons =
  H.div
    [ A.class "home__section--heading--buttons col-sm-7" ]
    [ H.button
      [ A.class "home__section--heading--buttons--inverse btn btn-primary" ]
      [ H.text "katso kaikki ilmoitukset" ]
    , H.button
      [ A.class "home__section--heading--buttons--normal btn btn-primary" ]
      [ H.text "jätä ilmoitus" ]
    ]

sectionHeader : String -> H.Html Msg
sectionHeader title =
  H.div
    [ A.class "home__section--heading--text col-sm-5" ]
    [ H.text title ]

listFourAds : Model -> H.Html Msg
listFourAds model =
  H.div
    []
    (ListAds.viewAds (List.take 4 model.listAds.ads))

-- LIST USERS --

listUsers : Model -> H.Html Msg
listUsers model =
  H.div
    [ A.class "home__list-users" ]
    [ H.div
      [ A.class "home__section--container" ]
      [ listUsersHeading
      , listThreeUsers model
      ]
     ]

listUsersHeading : H.Html Msg
listUsersHeading =
  H.div
    [ A.class "home__section--heading row" ]
    [ sectionHeader "Löydä tradenomi"
    , listUsersButtons
    ]

listUsersButtons : H.Html Msg
listUsersButtons =
  H.div
    [ A.class "home__section--heading--buttons col-sm-7" ]
    [ H.button
      [ A.class "home__section--heading--buttons--inverse btn btn-primary" ]
      [ H.text "katso kaikki tradenomit" ]
    , H.button
      [ A.class "home__section--heading--buttons--normal btn btn-primary" ]
      [ H.text "muokkaa omaa profiilia" ]
    ]

listThreeUsers : Model -> H.Html Msg
listThreeUsers model =
  H.div
    [ A.class "row" ]
    (List.map ListUsers.viewUser (List.take 3 model.listUsers.users))

  -- TRADENOMIITTI AD --

tradenomiittiSection : H.Html Msg
tradenomiittiSection =
  H.div
    [ A.class "home__tradenomiitti--background" ]
    [ H.div
        [ A.class "home__tradenomiitti--container" ]
        [ tradenomiittiRow ]
    ]
tradenomiittiRow : H.Html Msg
tradenomiittiRow =
  H.div
    [ A.class "row"]
    [ H.div [ A.class "home__tradenomiitti--info-container  col-md-6" ] [ tradenomiittiInfo ]
    , tradenomiImage
    ]

tradenomiittiInfo : H.Html Msg
tradenomiittiInfo =
  H.div
    [ A.class "home__tradenomiitti--info" ]
    [ tradenomiittiHeader
    , tradenomiittiInfoText
    , readMoreButton
    ]

tradenomiittiHeader : H.Html Msg
tradenomiittiHeader =
  H.h2
    [ A.class "home__tradenomiitti--info--header" ]
    [ H.text "Lorem ipsum dolorem salet" ]

tradenomiittiInfoText : H.Html Msg
tradenomiittiInfoText =
  H.p
    [ A.class "home__tradenomiitti--info--text" ]
    [ H.text "Tähän kuvaava teksti Tradenomiitistä. Hyötynäkökuma, eli mitä täällä voi tehdä ja miksi pitäisi liittyä. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua." ]

readMoreButton : H.Html Msg
readMoreButton =
  H.button
   [ A.class "home__tradenomiitti--info--read-more-button btn btn-primary" ]
   [ H.text "Lue lisää" ]

tradenomiImage : H.Html Msg
tradenomiImage =
  H.div
    [ A.class "col-md-6" ]
    [ H.img
      [ A.class "home__tradenomiitti--image"
      , A.src "/static/tral_person_image_square_1.jpg"
      ]
      []
    ]
