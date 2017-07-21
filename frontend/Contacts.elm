module Contacts exposing (..)

import Ad
import Common
import Html as H
import Html.Attributes as A
import Http
import Json.Decode as Json
import Models.User exposing (Contact, User)
import Profile.View
import State.Contacts exposing (..)
import Translation exposing (T)
import Util exposing (UpdateMessage, ViewMessage(..))


getContacts : Cmd (UpdateMessage Msg)
getContacts =
    Http.get "/api/kontaktit" (Json.list Models.User.contactDecoder)
        |> Util.errorHandlingSend GetContacts


initTasks : Cmd (UpdateMessage Msg)
initTasks =
    getContacts


type Msg
    = GetContacts (List Contact)


update : Msg -> Model -> ( Model, Cmd msg )
update msg model =
    case msg of
        GetContacts list ->
            { model | contacts = list } ! []


view : T -> Model -> Maybe User -> H.Html (ViewMessage msg)
view t model userMaybe =
    case userMaybe of
        Just user ->
            H.div
                [ A.class "contacts" ]
                [ Common.profileTopRow t user False Common.ContactsTab (H.div [] [])
                , H.div
                    [ A.class "container" ]
                    [ H.div
                        [ A.class "row" ]
                        [ H.div
                            [ A.class "col-xs-12" ]
                            [ H.h1 [ A.class "contacts__heading" ]
                                [ H.text <| t "contacts.heading" ]
                            ]
                        ]
                    ]
                , H.div
                    [ A.class "container last-row" ]
                    (List.indexedMap
                        (\i row ->
                            H.div
                                [ A.classList
                                    [ ( "row", True )
                                    , ( "contacts__row", True )
                                    , ( "contacts__row--first", i == 0 )
                                    ]
                                ]
                                row
                        )
                        (Common.chunk2 (List.map (renderContact t) model.contacts))
                    )
                ]

        _ ->
            H.div [] []


renderContact : T -> Contact -> H.Html (ViewMessage msg)
renderContact t contact =
    H.div
        [ A.class "col-xs-12 col-sm-6 contacts__item-container"
        ]
        [ Ad.viewDate t contact.createdAt
        , H.p
            [ A.class "contacts__intro-text" ]
            [ H.text contact.introText ]
        , Profile.View.businessCardView contact.user contact.businessCard
        ]
