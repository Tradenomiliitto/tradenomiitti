module User exposing (..)

import Html as H
import Html.Attributes as A
import Html.Events as E
import Http
import Json.Decode as Json
import Json.Encode as JS
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
  | ProfileMessage Profile.Msg
  | Refresh Int

update : Msg -> Model -> ( Model, Cmd (UpdateMessage Msg))
update msg model =
  case msg of
    UpdateUser updatedUser ->
      { model
        | user = Just updatedUser
        , addingContact = False
      } ! []

    UpdateAds ads ->
      { model | ads = ads } ! []

    ProfileMessage Profile.StartAddContact ->
      { model
        | addingContact = True
        , addContactText = ""
      } ! []
    ProfileMessage (Profile.ChangeContactAddingText str) ->
      { model | addContactText = str} ! []
    ProfileMessage (Profile.AddContact user) ->
      model ! [ addContact user model.addContactText ]

    ProfileMessage _ ->
      model ! [] -- only handle profile messages that we care about

    Refresh userId ->
      model ! [ getUser userId ]


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

addContact : User -> String -> Cmd (UpdateMessage Msg)
addContact user str =
  Http.post ("/api/kontaktit/" ++ (toString user.id))
    (Http.jsonBody (JS.string str)) (Json.succeed ())
    |> Util.errorHandlingSend (always (Refresh user.id))



-- VIEW

view : Model -> H.Html (ViewMessage Msg)
view model =
  let
    profileInit = State.Profile.init
    profile = { profileInit | ads = model.ads }
    views = model.user
      |> Maybe.map
        (\u ->
           List.map (Util.localViewMap ProfileMessage) <| Profile.View.viewUser profile False (contactUser u) u)
      |> Maybe.withDefault []

  in
   H.div [] views


contactUser : User -> H.Html Profile.Msg
contactUser user =
  if user.contacted
  then
    H.div
      [ A.class "col-md-6 user-page__edit-or-contact-user"]
      [ H.p [] [ H.text "Olet lähettänyt käyntikortin tälle tradenomille." ]
      ]
  else
    H.div
      [ A.class "col-md-6 user-page__edit-or-contact-user"]
      [ H.p [] [ H.text ("Voisiko " ++ user.name ++ " auttaa sinua? Jaa käyntikorttisi tästä. ") ]
      , H.button [ E.onClick Profile.StartAddContact
                , A.class "btn btn-primary"
                ] [ H.text "Ota yhteyttä" ]
      ]
