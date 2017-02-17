import Html as H
import Html.Attributes as A
import Html.Events as E
import Http
import Json.Decode as Json
import Nav exposing (..)
import Navigation
import Profile
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
  , profile : Maybe User.User
  }

init : Navigation.Location -> ( Model, Cmd Msg )
init location =
  let
    model =
      { route = parseLocation location
      , rootUrl = location.origin
      , user = Nothing
      , profile = Nothing
      }

   -- We want to react initially to UrlChange as well
    urlCmd = Navigation.modifyUrl (routeToPath (parseLocation location))
    profileCmd = Profile.getMe GetProfile
  in
    model ! [ urlCmd, profileCmd ]


-- UPDATE

type Msg
  = NewUrl Route
  | UrlChange Navigation.Location
  | UserMessage User.Msg
  | GetProfile (Result Http.Error User.User)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    NewUrl route ->
      ( model ,  Navigation.newUrl (routeToPath route) )

    UrlChange location ->
      case (parseLocation location) of
        User userId ->
          ( { model
              | route = (parseLocation location)
            }, Cmd.map UserMessage <| User.getUser userId)
        newRoute ->
          ( { model
              | route = newRoute
            }, Cmd.none )

    UserMessage msg ->
      let
        (userModel, cmd) = User.update msg model.user
      in
        ( {model | user = userModel}, Cmd.map UserMessage cmd )

    GetProfile (Err _) ->
      { model | profile = Nothing } ! []

    GetProfile (Ok user) ->
      { model | profile = Just user } ! []

--SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none

-- VIEW

view : Model -> H.Html Msg
view model =
  H.div []
    [ loginHandler model
    , navigation model
    , viewPage model
    ]

--TODO move navbar code to Nav.elm

loginHandler : Model -> H.Html Msg
loginHandler model =
  let
    loginUrl = model.rootUrl ++ "/login?path=" ++ (routeToPath model.route)
    returnParameter = Window.encodeURIComponent loginUrl
  in
    case model.profile of
      Just _ ->
        H.a [ A.href "/logout" ]
          [ H.text "Kirjaudu ulos" ]
      Nothing ->
        H.a [ A.href
              <| "https://tunnistus.avoine.fi/sso-login/?service=tradenomiitti&return="
              ++ returnParameter ]
          [ H.text "Kirjaudu sisään" ]


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
