module User exposing (..)

import Models.Ad exposing (Ad)
import Http
import Json.Decode as Json
import Models.User exposing (User)


type alias Model =
  { user : Maybe User
  }

init : Model
init =
  { user = Nothing
  }


-- UPDATE

type Msg
  = UpdateUser (Result Http.Error User)
  | UpdateAds (Result Http.Error (List Ad))
  | NoOp

update : Msg -> Model -> ( Model, Cmd Msg)
update msg model =
  case msg of
    UpdateUser (Ok updatedUser) ->
      { model | user = Just updatedUser } ! []
    -- TODO: show error
    UpdateUser (Err _) ->
      { model | user = Nothing } ! []

    UpdateAds _ ->
      model ! [] -- TODO

    NoOp ->
      model ! []

getUser : Int -> Cmd Msg
getUser userId =
  let
    url = "/api/tradenomit/" ++ toString userId
    request = Http.get url Models.User.userDecoder
  in
    Http.send UpdateUser request

getAds : Int -> Cmd Msg
getAds userId =
  let
    url = "/api/ilmoitukset/tradenomilta/" ++ toString userId
    request = Http.get url (Json.list Models.Ad.adDecoder)
  in
    Http.send UpdateAds request


-- VIEW

view whatever = Debug.crash "Not implemented"
