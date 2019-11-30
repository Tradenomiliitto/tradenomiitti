module Contacts exposing (Msg(..), getContacts, initTasks, renderContact, update, view)

import Ad
import Common
import Html as H
import Html.Attributes as A
import Http
import Json.Decode as Json
import Models.User exposing (Contact, User)
import Profile.PublicInfo
import State.Contacts exposing (..)
import Time
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
            ( { model | contacts = list }
            , Cmd.none
            )


view : T -> Time.Zone -> Model -> Maybe User -> H.Html (ViewMessage msg)
view t timeZone model userMaybe =
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
                        (Common.chunk2 (List.map (renderContact t timeZone) model.contacts))
                    )
                ]

        _ ->
            H.div [] []


renderContact : T -> Time.Zone -> Contact -> H.Html (ViewMessage msg)
renderContact t timeZone contact =
    H.div
        [ A.class "col-xs-12 col-sm-6 contacts__item-container"
        ]
        [ Ad.viewDate t timeZone contact.createdAt
        , H.p
            [ A.class "contacts__intro-text" ]
            [ H.text contact.introText ]
        , Profile.PublicInfo.businessCardView t contact.user contact.businessCard
        ]
