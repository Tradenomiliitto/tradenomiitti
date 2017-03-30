module User exposing (..)

import Html as H
import Http
import Json.Decode as Json
import Link exposing (AppMessage)
import Models.Ad exposing (Ad)
import Models.User exposing (User)
import Profile.View
import Profile.Main as Profile
import State.Profile
import State.User exposing (..)


-- UPDATE

type Msg
  = UpdateUser (Result Http.Error User)
  | UpdateAds (Result Http.Error (List Ad))
  | ProfileMessage (AppMessage Profile.Msg)
  | NoOp

update : Msg -> Model -> ( Model, Cmd Msg)
update msg model =
  case msg of
    UpdateUser (Ok updatedUser) ->
      { model | user = Just updatedUser } ! []
    UpdateUser (Err _) ->
      { model | user = Nothing } ! [] -- TODO: show error

    UpdateAds (Ok ads) ->
      { model | ads = ads } ! []

    UpdateAds (Err _) ->
      model ! [] -- TODO: show error

    ProfileMessage message ->
      model ! [] -- TODO not like this

    NoOp ->
      model ! []

getUser : Int -> Cmd Msg
getUser userId =
  let
    url = "/api/profiilit/" ++ toString userId
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

view : Model -> H.Html (AppMessage Profile.Msg)
view model =
  let
    profileInit = State.Profile.init
    profile = { profileInit | ads = model.ads }
    views = model.user
      |> Maybe.map (\u ->  Profile.View.viewUser profile False u)
      |> Maybe.withDefault []

  in
   H.div [] views
