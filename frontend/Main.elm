import Html exposing (..)
import Html.Attributes exposing (href)
import Html.Events exposing (onClick)
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

view : Model -> Html Msg
view model =
  let
    loginUrl = model.rootUrl ++ "/login"
    returnParameter = Window.encodeURIComponent loginUrl
  in
    div []
    [ a
      [ href
        <| "https://tunnistus.avoine.fi/sso-login/?service=tradenomiitti&return="
        ++ returnParameter ]
      [ text "Kirjaudu sisään" ]
    , navigation model
    , viewPage model 
    ]

--TODO move navbar code to Nav.elm

navigation : Model -> Html Msg
navigation model =
  nav [Html.Attributes.class "navbar navbar-default navbar-fixed-top"]
    [ div [] 
    [ div [Html.Attributes.class "container"] [
      (div [Html.Attributes.class "navbar-header"]
      [ logo ]),
      navigationList model
    ]]]

logo : Html Msg
logo =
  a [ Html.Attributes.href "/"] [text "Tradenomiitti" ]


navigationList : Model -> Html Msg
navigationList model =
  div [Html.Attributes.id "navbar",
      Html.Attributes.class "navbar-collapse collapse"] 
    [ navigationListCenter model
    , navigationListRight model]

navigationListCenter : Model -> Html Msg
navigationListCenter model =
  ul [Html.Attributes.class "nav navbar-nav navbar-center"]
    (List.map viewLink [Home, NotFound])

navigationListRight : Model -> Html Msg
navigationListRight model =
  ul [Html.Attributes.class "nav navbar-nav navbar-right"]
    (List.map viewLink [Info, User 1])

viewLink : Route -> Html Msg
viewLink route = li [] 
  [(a [onClick (NewUrl route)]
   [text (routeToString route)])]


viewPage : Model -> Html Msg
viewPage model =
  case model.route of
    User userId -> map UserMessage <| User.view model.user
    route -> div [] [text (routeToString route)]



routeToString : Route -> String
routeToString route =
  case route of
    User userId -> "User"
    Home -> "Home"
    Info -> "Info"
    NotFound -> "Not Found"
