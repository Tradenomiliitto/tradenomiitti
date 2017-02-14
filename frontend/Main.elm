import Html exposing (..)
import Html.Attributes exposing (href)
import Html.Events exposing (onClick)
import Nav exposing (..)
import Navigation
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
  }

init : Navigation.Location -> ( Model, Cmd Msg )
init location =
  ({ route = parseLocation location
   , rootUrl = location.origin
   }, Cmd.none )

-- UPDATE

type Msg
    = NewUrl Route
    | UrlChange Navigation.Location

update : Msg -> Model -> (Model, Cmd msg)
update msg model =
    case msg of
        NewUrl route ->
            ( { model | route = route } , Navigation.newUrl (routeToPath route) )

        UrlChange location -> ( { model | route = (parseLocation location) }, Cmd.none )


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
    , div [] [text ("Current page: " ++ (routeToString model.route))] ]


navigation : Model -> Html Msg
navigation model =
    ul []
        (List.map viewLink [User 1, Home, Info])

viewLink : Route -> Html Msg
viewLink route = li [ onClick (NewUrl route) ] [ text (routeToString route) ]

routeToString : Route -> String
routeToString route =
    case route of
        User userId -> "User"
        Home -> "Home"
        Info -> "Info"
        NotFound -> "Not Found"
