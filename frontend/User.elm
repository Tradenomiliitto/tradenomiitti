module User exposing (..)

import Html as H
import Http
import Json.Decode as Json
import Models.Ad exposing (Ad)
import Models.User exposing (User)
import Profile.Main as Profile
import Profile.View
import State.Profile
import State.User exposing (..)
import Util exposing (ViewMessage, UpdateMessage(..))


-- UPDATE

type Msg
  = UpdateUser User
  | UpdateAds (List Ad)
  | ProfileMessage (ViewMessage Profile.Msg)
  | NoOp

update : Msg -> Model -> ( Model, Cmd Msg)
update msg model =
  case msg of
    UpdateUser updatedUser ->
      { model | user = Just updatedUser } ! []

    UpdateAds ads ->
      { model | ads = ads } ! []

    ProfileMessage _ ->
      model ! [] -- TODO not like this

    NoOp ->
      model ! []

initTasks : Int -> Cmd (UpdateMessage Msg)
initTasks userId =
  Cmd.batch
    [ getUser userId
    , getAds userId
    ]

getUser : Int -> Cmd (UpdateMessage Msg)
getUser userId =
  let
    url = "/api/profiilit/" ++ toString userId
    request = Http.get url Models.User.userDecoder
  in
    Util.errorHandlingSend UpdateUser request

getAds : Int -> Cmd (UpdateMessage Msg)
getAds userId =
  let
    url = "/api/ilmoitukset/tradenomilta/" ++ toString userId
    request = Http.get url (Json.list Models.Ad.adDecoder)
  in
    Util.errorHandlingSend UpdateAds request


-- VIEW

view : Model -> H.Html (ViewMessage Profile.Msg)
view model =
  let
    profileInit = State.Profile.init
    profile = { profileInit | ads = model.ads }
    views = model.user
      |> Maybe.map (\u ->  Profile.View.viewUser profile False u)
      |> Maybe.withDefault []

  in
   H.div [] views
