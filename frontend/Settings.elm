module Settings exposing (..)

import Common
import Html as H
import Html.Attributes as A
import Html.Events as E
import Http
import Models.User exposing (Settings, User)
import State.Settings exposing (..)
import State.Util exposing (SendingStatus(..))
import Util exposing (UpdateMessage(..), ViewMessage(..))


type Msg
    = GetSettings Settings
    | UpdateSettings (Result Http.Error ())
    | ToggleEmailsForAnswers Settings
    | ToggleEmailsForBusinessCards Settings
    | ToggleEmailsForNewAds Settings
    | ChangeEmailAddress Settings String
    | Save Settings


getSettings : Cmd (UpdateMessage Msg)
getSettings =
    Http.get "/api/asetukset" Models.User.settingsDecoder
        |> Util.errorHandlingSend GetSettings


updateSettings : Settings -> Cmd (UpdateMessage Msg)
updateSettings settings =
    Util.put "/api/asetukset" (Models.User.settingsEncode settings)
        |> Http.send (LocalUpdateMessage << UpdateSettings)


initTasks : Cmd (UpdateMessage Msg)
initTasks =
    getSettings


update : Msg -> Model -> ( Model, Cmd (UpdateMessage Msg) )
update msg model =
    case msg of
        GetSettings settings ->
            { model | settings = Just settings } ! []

        UpdateSettings (Ok _) ->
            { model | sending = FinishedSuccess "" } ! []

        UpdateSettings (Err _) ->
            { model | sending = FinishedFail } ! []

        ToggleEmailsForAnswers settings ->
            { model
                | sending = NotSending
                , settings =
                    Just
                        { settings
                            | emails_for_answers = not settings.emails_for_answers
                        }
            }
                ! []

        ToggleEmailsForBusinessCards settings ->
            { model
                | sending = NotSending
                , settings =
                    Just
                        { settings
                            | emails_for_businesscards = not settings.emails_for_businesscards
                        }
            }
                ! []

        ToggleEmailsForNewAds settings ->
            { model
                | sending = NotSending
                , settings =
                    Just
                        { settings
                            | emails_for_new_ads = not settings.emails_for_new_ads
                        }
            }
                ! []

        ChangeEmailAddress settings str ->
            { model
                | sending = NotSending
                , settings =
                    Just
                        { settings
                            | email_address = str
                        }
            }
                ! []

        Save settings ->
            { model | sending = Sending } ! [ updateSettings settings ]


view : Model -> Maybe User -> H.Html (ViewMessage Msg)
view model userMaybe =
    case ( model.settings, userMaybe ) of
        ( Just settings, Just user ) ->
            viewSettingsPage model settings user

        ( Nothing, Just user ) ->
            H.div
                []
                [ Common.profileTopRow user False Common.SettingsTab (H.div [] []) ]

        _ ->
            H.div [] []


viewSettingsPage : Model -> Settings -> User -> H.Html (ViewMessage Msg)
viewSettingsPage model settings user =
    H.div
        []
        [ Common.profileTopRow user False Common.SettingsTab (H.div [] [])
        , H.map LocalViewMessage <| viewSettings model settings
        ]


viewSettings : Model -> Settings -> H.Html Msg
viewSettings model settings =
    H.div
        [ A.class "container" ]
        [ H.div
            [ A.class "row" ]
            [ H.div
                [ A.class "col-xs-12" ]
                [ H.h1 [ A.class "settings__heading" ] [ H.text "Asetukset" ] ]
            , H.form
                []
                [ H.div
                    [ A.class "col-xs-12 col-sm-6" ]
                    [ H.h2 [ A.class "settings__subsection-heading" ] [ H.text "Sähköpostit" ]
                    , H.p [] [ H.text "Voit itse valita missä tilanteissa Tradenomiitti lähettää sinulle viestin sähköpostitse. Sähköposti varmistaa sen, että saat tiedon uusista kontakteista, sinua koskevista ilmoituksista ja saamistasi vastauksista." ]
                    ]
                , H.div
                    [ A.class "col-xs-12 col-sm-6" ]
                    [ H.div
                        [ A.class "form-group"
                        ]
                        [ H.label
                            [ A.for "email-address"
                            ]
                            [ H.text "Sähköpostiosoite" ]
                        , H.input
                            [ A.type_ "text"
                            , A.class "form-control"
                            , A.id "email-address"
                            , A.value settings.email_address
                            , E.onInput (ChangeEmailAddress settings)
                            ]
                            []
                        ]
                    , H.div
                        [ A.class "checkbox" ]
                        [ H.label
                            []
                            [ H.input
                                [ A.type_ "checkbox"
                                , E.onClick <| ToggleEmailsForBusinessCards settings
                                , A.checked settings.emails_for_businesscards
                                ]
                                []
                            , H.text "Ilmoitus uudesta kontaktista/käyntikortista"
                            ]
                        ]
                    , H.div
                        [ A.class "checkbox" ]
                        [ H.label
                            []
                            [ H.input
                                [ A.type_ "checkbox"
                                , E.onClick <| ToggleEmailsForAnswers settings
                                , A.checked settings.emails_for_answers
                                ]
                                []
                            , H.text "Ilmoitus uudesta vastauksesta jättämääsi kysymykseen"
                            ]
                        ]
                    , H.div
                        [ A.class "checkbox" ]
                        [ H.label
                            []
                            [ H.input
                                [ A.type_ "checkbox"
                                , E.onClick <| ToggleEmailsForNewAds settings
                                , A.checked settings.emails_for_new_ads
                                ]
                                []
                            , H.text "Kootut sinulle suunnatut ilmoitukset (viikottainen)"
                            ]
                        ]
                    ]
                ]
            ]
        , H.div
            [ A.class "row last-row settings__save" ]
            [ H.div
                [ A.class "col-xs-12" ]
                [ H.button
                    [ E.onClick (Save settings)
                    , A.class "btn btn-default"
                    ]
                    [ H.text "Tallenna" ]
                , H.p
                    []
                    [ H.text <| sendingToText model.sending ]
                ]
            ]
        ]


sendingToText : SendingStatus -> String
sendingToText sending =
    case sending of
        NotSending ->
            ""

        Sending ->
            "Tallenetaan…"

        FinishedSuccess _ ->
            "Tallennus onnistui"

        FinishedFail ->
            "Tallenuksessa meni jotain pieleen"
