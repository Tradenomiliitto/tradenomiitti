import Html as H 
import Html.Attributes as A
import Html.Events as E
import Json.Decode as Json
import Nav exposing (..)
import Navigation
import User
import Window


main =
  Navigation.program UrlChange
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }

type alias Model =
  { route : Route
  , rootUrl : String
  , user : Maybe User.User
  }

init : Navigation.Location -> ( Model, Cmd Msg )
init location =
  ({ route = parseLocation location
   , rootUrl = location.origin
   , user = Nothing }
   -- url is modified on init to send UrlChange message
   , Navigation.modifyUrl (routeToPath (parseLocation location)))

-- UPDATE

type Msg
  = NewUrl Route
  | UrlChange Navigation.Location
  | UserMessage User.Msg

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    NewUrl route ->
      ( model ,  Navigation.newUrl (routeToPath route) )

    UrlChange location ->
      case (parseLocation location) of
        User userId ->
          ( { model | route = (parseLocation location) }, Cmd.map UserMessage <| User.getUser userId)
        newRoute ->
          ( { model | route = newRoute }, Cmd.none )

    UserMessage msg ->
      let
        (userModel, cmd) = User.update msg model.user
      in
        ( {model | user = userModel}, Cmd.map UserMessage cmd )

--SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none

-- VIEW

view : Model -> H.Html Msg
view model =
  let
    loginUrl = model.rootUrl ++ "/login"
    returnParameter = Window.encodeURIComponent loginUrl
  in
    H.div []
    [ H.a
      [ A.href
        <| "https://tunnistus.avoine.fi/sso-login/?service=tradenomiitti&return="
        ++ returnParameter ]
      [ H.text "Kirjaudu sisään" ]
    , navigation model
    , viewPage model
    ]

--TODO move navbar code to Nav.elm

navigation : Model -> H.Html Msg
navigation model =
  H.nav
    [ A.class "navbar navbar-default navbar-fixed-top" ]
    [ H.div
      []
      [ navigationList model ]
    ]

logo : H.Html Msg
logo =
  H.li
    [ A.class "navbar-left" ]
    [ H.a
      [ A.id "logo"
      , A.href "/"
      ]
      [ H.text "Tradenomiitti" ]
    ]


navigationList : Model -> H.Html Msg
navigationList model =
  H.ul
    [ A.class "nav navbar-nav" ]
    (List.concat
      [ [logo]
      , List.map viewLink [ ListUsers, ListAds, CreateAd ]
      , List.map viewLinkRight [ Profile, Info ]
      ])

viewLink : Route -> H.Html Msg
viewLink route =
  H.li
    []
    [ link route ]

viewLinkRight : Route -> H.Html Msg
viewLinkRight route =
  H.li 
    [ A.class "navbar-right" ]
    [ link route ]

link : Route -> H.Html Msg
link route = 
  let 
    action = 
      E.onWithOptions
        "click"
        { stopPropagation = False
        , preventDefault = True
        }
        (Json.succeed <| NewUrl route)
  in 
    H.a 
      [ action
      , A.href (routeToPath route)
      ]
      [ H.text (routeToString route) ]

viewPage : Model -> H.Html Msg
viewPage model =
  case model.route of
    User userId ->
      H.map UserMessage <| User.view model.user
    route ->
      H.div
        []
        [ H.text (routeToString route) ]



routeToString : Route -> String
routeToString route =
  case route of
    User userId ->
      "Käyttäjä " ++ (toString userId)
    Profile ->
      "Oma Profiili"
    Home ->
      "Home"
    Info ->
      "Tietoa"
    NotFound ->
      "Ei löytynyt"
    ListUsers ->
      "Tradenomit"
    ListAds ->
      "Hakuilmoitukset"
    CreateAd ->
      "Jätä ilmoitus"


