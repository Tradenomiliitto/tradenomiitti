import Html exposing (..)
import Html.Attributes exposing (href)
import Html.Events exposing (onClick)
import Nav exposing (..)
import Navigation
import User

main =
  Navigation.program UrlChange
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }


type alias Model = 
    {
        route : Route,
        user : Maybe User.User
    }

init : Navigation.Location -> ( Model, Cmd Msg )
init location = ( { route = parseLocation location, user = Nothing }, Cmd.none)

-- UPDATE

type Msg
    = NewUrl Route
    | UrlChange Navigation.Location
    | UserMessage User.Msg

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        NewUrl route ->
            ( { model | route = route } , Cmd.batch [ Navigation.newUrl (routeToPath route), Cmd.map UserMessage <| User.getUser 5])

        UrlChange location -> ( { model | route = (parseLocation location) }, Cmd.none )

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
    div []
    [ a
      [ href "https://tunnistus.avoine.fi/sso-login/?service=tradenomiitti&return=http%3A%2F%2Flocalhost%3A3000%2Flogin" ]
      [ text "Kirjaudu sisään" ]
    , navigation model
    , viewPage model 
    ]


navigation : Model -> Html Msg
navigation model =
    ul []
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
