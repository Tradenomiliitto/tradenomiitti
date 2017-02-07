import Html exposing (..)
import Html.Events exposing (onClick)
import Navigation

main =
  Navigation.program UrlChange 
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }

type alias Model = {}
model : Model
model =
     {}

init : Navigation.Location -> ( Model, Cmd Msg )
init location =
    ( {}, Cmd.none  
    )

type Route = User Int | Questions | Info

-- UPDATE

type Msg =
    NewUrl Route 
    | UrlChange Navigation.Location

update : Msg -> Model -> (Model, Cmd msg)
update msg model =
    case msg of 
        NewUrl route ->
            ( model, Navigation.newUrl (routeToUrl route) )

        UrlChange location -> ( model, Cmd.none )

routeToUrl : Route -> String
routeToUrl route =
    case route of
        User userId ->
            "/user/" ++ (toString userId)
        Questions ->
            "/questions"
        Info ->
            "/info"

--SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none

-- VIEW

view : Model -> Html Msg
view model =
    ul []
        (List.map viewLink [User 1, Questions, Info])

viewLink : Route -> Html Msg
viewLink route = li [ onClick (NewUrl route) ] [ text (routeToString route) ]

routeToString : Route -> String
routeToString route = 
    case route of 
        User userId -> "Profile"
        Questions -> "Questions"
        Info -> "Info"