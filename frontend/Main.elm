import Html exposing (..)
import Html.Attributes exposing (href)
import Html.Events exposing (onClick)
import Http
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

view : Model -> Html Msg
view model =
  div []
    [ loginHandler model
    , navigation model
    , viewPage model 
    ]


loginHandler : Model -> Html Msg
loginHandler model =
  let
    loginUrl = model.rootUrl ++ "/login?path=" ++ (routeToPath model.route)
    returnParameter = Window.encodeURIComponent loginUrl
  in
    case model.profile of
      Just _ ->
        a [ href "/logout" ]
          [ text "Kirjaudu ulos" ]
      Nothing ->
        a [ href
              <| "https://tunnistus.avoine.fi/sso-login/?service=tradenomiitti&return="
              ++ returnParameter ]
          [ text "Kirjaudu sisään" ]


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
