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


navigation : Model -> Html Msg
navigation model =
  ul [Html.Attributes.id "nav"]
    (List.map viewLink [User 1, Home, Info])

viewLink : Route -> Html Msg
viewLink route = li [ onClick (NewUrl route) ] [ text (routeToString route) ]


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
