module Contacts exposing (..)

import Ad
import Common
import Html as H
import Html.Attributes as A
import Http
import Json.Decode as Json
import Models.User exposing (User, Contact)
import Profile.View
import State.Contacts exposing (..)
import Util exposing (ViewMessage(..), UpdateMessage)

getContacts : Cmd (UpdateMessage Msg)
getContacts =
  Http.get "/api/kontaktit" (Json.list Models.User.contactDecoder)
    |> Util.errorHandlingSend GetContacts

initTasks : Cmd (UpdateMessage Msg)
initTasks = getContacts

type Msg
  = GetContacts (List Contact)

update : Msg -> Model -> (Model, Cmd msg)
update msg model =
  case msg of
    GetContacts list ->
      { model | contacts = list } ! []

view : Model -> Maybe User -> H.Html (ViewMessage msg)
view model userMaybe =
  case userMaybe of
    Just user ->
      H.div
        []
        [ Common.profileTopRow user False Common.ContactsTab (H.div [] [])
        , H.div
          [ A.class "container contacts"]
          [ H.div
            [A.class "row" ]
            [ H.div
              [ A.class "col-xs-12" ]
              [ H.h1 [ A.class "contacts__heading" ] [ H.text "Käyntikortit" ] ]
            ]
          , H.div
              [ A.class "row contacts__row last-row" ]
              (List.map renderContact model.contacts)
          ]
        ]
    _ ->
      H.div [] []

renderContact : Contact -> H.Html (ViewMessage msg)
renderContact contact =
  H.div
    [ A.class "col-xs-12 col-sm-6 contacts__item-container"
    ]
    [ Ad.viewDate contact.createdAt
    , H.p
      [ A.class "contacts__intro-text" ]
      [ H.text contact.introText ]
    , Profile.View.businessCardView contact.user contact.businessCard
    ]
