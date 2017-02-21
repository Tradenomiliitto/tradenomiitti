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

main : Program Never Model Msg
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
  , user : User.Model
  , profile : User.Model
  }

init : Navigation.Location -> ( Model, Cmd Msg )
init location =
  let
    model =
      { route = parseLocation location
      , rootUrl = location.origin
      , user = User.init
      , profile = { user = Nothing, spinning = True }
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
      let
        newRoute = parseLocation location
        modelWithRoute = { model | route = newRoute }
        ( newModel, cmd ) =
          case newRoute of
            User userId ->
              let
                (userModel, cmd) =
                  User.update (User.GetUser userId) modelWithRoute.user
              in
                ({ modelWithRoute | user = userModel }, Cmd.map UserMessage cmd)

            newRoute ->
              (modelWithRoute, Cmd.none)
      in
        newModel ! [ cmd ]

    UserMessage msg ->
      let
        (userModel, cmd) = User.update msg model.user
      in
        ( { model | user = userModel}, Cmd.map UserMessage cmd )

    GetProfile (Err _) ->
      let
        profile = model.profile
      in
        { model | profile = { profile | spinning = False } } ! []

    GetProfile (Ok user) ->
      let
        profile = model.profile
      in
        { model | profile = { profile | user = Just user, spinning = False } } ! []

--SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none

-- VIEW

view : Model -> H.Html Msg
view model =
  H.div []
    [ navigation model
    , viewPage model
    ]

--TODO move navbar code to Nav.elm

loginHandler : Model -> H.Html Msg
loginHandler model =
  let
    loginUrl = model.rootUrl ++ "/login?path=" ++ (routeToPath model.route)
    returnParameter = Window.encodeURIComponent loginUrl
  in
    case model.profile.user of
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
    [ navigationList model
    ]

logo : H.Html Msg
logo =
  H.li
    [ A.class "navbar-left" ]
    [ H.a
      [ A.id "logo"
      , A.href "/"
      ]
      [ H.img
          [ A.alt "Tradenomiitti"
          , A.src "/static/tradenomiitti_logo.svg"
          , A.width 163
          ]
          []
      ]
    ]


navigationList : Model -> H.Html Msg
navigationList model =
  H.ul
    [ A.class "nav navbar-nav" ]
    [ logo
    , viewLink ListUsers
    , verticalBar
    , viewLink ListAds
    , viewLinkInverse CreateAd
    -- Right aligned elements are float: right, ergo reverse order in DOM
    , viewLinkRight Profile
    , verticalBarRight
    , viewLinkRight Info
    ]

verticalBar : H.Html msg
verticalBar =
  H.li
    [ A.class <| "navbar__vertical-bar navbar-center" ]
    []

verticalBarRight : H.Html msg
verticalBarRight =
  H.li
    [ A.class "navbar__vertical-bar--right navbar-right" ]
    [ H.div
        []
        []
    ]

viewLinkInverse : Route -> H.Html Msg
viewLinkInverse route =
  H.li
    [ A.class "navbar-center navbar__inverse-button" ]
    [ link route ]

viewLink : Route -> H.Html Msg
viewLink route =
  H.li
    [ A.class "navbar-center" ]
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
  let
    content =
      case model.route of
        User userId ->
          H.map UserMessage <| User.view model.user
        Profile ->
          Profile.view model.profile (loginHandler model) UserMessage
        route ->
          notImplementedYet
  in
    H.div
      [ A.class "container app-content" ]
      [ content ]

notImplementedYet : H.Html Msg
notImplementedYet =
  H.div
    [ A.id "not-implemented" ]
    [ H.text "Tätä ominaisuutta ei ole vielä toteutettu" ]


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
