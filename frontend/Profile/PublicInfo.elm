module Profile.PublicInfo exposing (businessCard, businessCardData, businessCardDataInput, businessCardDataView, businessCardView, contributionStatus, editing, fieldToString, location, locationSelect, optionPreselected, publicInfo, userDescription, userIdForAdmins, userInfoBox, userInfoBoxEditing, userInfoBoxEditing2)

import Common
import Html as H
import Html.Attributes as A
import Html.Events as E
import Json.Decode as Json
import Link
import Models.User exposing (User)
import Nav
import PlainTextFormat
import Profile.Main exposing (BusinessCardField(..), Msg(..))
import State.Config as Config
import State.Profile exposing (Model)
import SvgIcons
import Translation exposing (T)
import Util exposing (ViewMessage(..))


editing : T -> Model -> User -> H.Html Msg
editing t model user =
    H.div
        [ A.class "container-fluid" ]
        [ H.div
            [ A.class "container" ]
            [ H.div
                [ A.class "profile__editing--public-info row" ]
                [ publicInfo t model user
                , businessCard t user
                ]
            ]
        ]


publicInfo : T -> Model -> User -> H.Html Msg
publicInfo t model user =
    H.div
        [ A.class "col-sm-6 profile__editing--public-info--box" ]
        [ H.h3 [ A.class "profile__editing--public-info--header" ] [ H.text <| t "profile.publicInfo.heading" ]
        , H.p [ A.class "profile__editing--public-info--text" ] [ H.text <| t "profile.publicInfo.hint" ]
        , userInfoBoxEditing t model user
        ]


businessCard : T -> User -> H.Html Msg
businessCard t user =
    H.div
        [ A.class "col-sm-6 profile__editing--public-info--box" ]
        [ H.h3 [ A.class "profile__editing--public-info--header" ] [ H.text <| t "profile.businessCard.heading" ]
        , H.p [ A.class "profile__editing--public-info--text" ]
            [ H.text <| t "profile.businessCard.hint"
            , H.span [ A.class "profile__editing--bold" ] [ H.text <| t "profile.businessCard.visibleForRecipients" ]
            ]
        , case user.businessCard of
            Just businessCardValue ->
                businessCardData t user businessCardValue

            Nothing ->
                H.div [] [ H.text <| t "profile.businessCard.notFound" ]
        ]


businessCardData : T -> User -> Models.User.BusinessCard -> H.Html Msg
businessCardData t user businessCardParam =
    H.div
        [ A.class "profile__business-card" ]
        [ H.div [ A.class "profile__business-card--container" ]
            [ H.div
                [ A.class "profile__business-card--data" ]
                [ H.span [ A.class "user-page__pic" ] [ Common.picElementForUser user ]
                , H.div
                    [ A.class "inline profile__business-card--data--name-work" ]
                    [ H.h4 []
                        [ H.input
                            [ A.class "profile__business-card--name-work--input"
                            , A.placeholder <| t "profile.businessCardFields.name"
                            , A.value businessCardParam.name
                            , E.onInput (UpdateBusinessCard Profile.Main.Name)
                            ]
                            []
                        ]
                    , H.h5 []
                        [ H.input
                            [ A.class "profile__business-card--name-work--input"
                            , A.placeholder <| t "profile.businessCardFields.title"
                            , A.value businessCardParam.title
                            , E.onInput (UpdateBusinessCard Profile.Main.Title)
                            ]
                            []
                        ]
                    ]
                ]
            , H.div [ A.class "profile__business-card--data--contact" ]
                [ businessCardDataInput t businessCardParam Location
                , businessCardDataInput t businessCardParam Phone
                , businessCardDataInput t businessCardParam Email
                , businessCardDataInput t businessCardParam LinkedIn
                ]
            ]
        ]


businessCardView : T -> User -> Models.User.BusinessCard -> H.Html (ViewMessage msg)
businessCardView t user businessCardParam =
    H.div
        [ A.class "profile__business-card profile__business-card-view" ]
        [ H.div
            [ A.class "profile__business-card--container" ]
            [ H.a
                [ A.class "profile__business-card--data card-link"
                , Link.action (Nav.User user.id)
                ]
                [ H.span [ A.class "user-page__businesscard-view-pic" ] [ Common.picElementForUser user ]
                , H.div
                    [ A.class "inline profile__business-card--data--name-work" ]
                    [ H.h4 []
                        [ H.text businessCardParam.name ]
                    , H.h5 []
                        [ H.text businessCardParam.title ]
                    ]
                ]
            , H.div [ A.class "profile__business-card--data--contact" ]
                [ businessCardDataView businessCardParam Location
                , businessCardDataView businessCardParam Phone
                , businessCardDataView businessCardParam Email
                , businessCardDataView businessCardParam LinkedIn
                ]
            ]
        ]


businessCardDataInput : T -> Models.User.BusinessCard -> BusinessCardField -> H.Html Msg
businessCardDataInput t card field =
    let
        value =
            case field of
                Name ->
                    card.name

                Title ->
                    card.title

                Location ->
                    card.location

                Phone ->
                    card.phone

                Email ->
                    card.email

                LinkedIn ->
                    card.linkedin

        icon =
            case field of
                Location ->
                    [ SvgIcons.location ]

                Phone ->
                    [ SvgIcons.phone ]

                Email ->
                    [ SvgIcons.email ]

                LinkedIn ->
                    [ H.i [ A.class "fa fa-linkedin" ] [] ]

                _ ->
                    []

        class =
            A.classList
                [ ( "profile__business-card--input", True )
                , ( "profile__business-card--input--empty", value == "" )
                , ( "profile__business-card--input--filled", value /= "" )
                ]
    in
    H.p
        [ class ]
        [ H.span [ class, A.class "profile__business-card--input-icon" ] icon
        , H.input
            [ A.placeholder <| fieldToString t field
            , A.value value
            , E.onInput (UpdateBusinessCard field)
            ]
            []
        , H.hr [ A.class "profile__business-card--input-line", class ] []
        ]


businessCardDataView : Models.User.BusinessCard -> BusinessCardField -> H.Html msg
businessCardDataView card field =
    let
        value =
            case field of
                Name ->
                    card.name

                Title ->
                    card.title

                Location ->
                    card.location

                Phone ->
                    card.phone

                Email ->
                    card.email

                LinkedIn ->
                    card.linkedin

        icon =
            case field of
                Location ->
                    [ SvgIcons.location ]

                Phone ->
                    [ SvgIcons.phone ]

                Email ->
                    [ SvgIcons.email ]

                LinkedIn ->
                    [ H.i [ A.class "fa fa-linkedin" ] [] ]

                _ ->
                    []

        class =
            A.classList
                [ ( "profile__business-card--input", True )
                , ( "profile__business-card--input--filled", value /= "" )
                ]
    in
    if String.length value > 0 then
        H.p
            [ class ]
            [ H.span [ class, A.class "profile__business-card--input-icon" ] icon
            , H.span [] [ H.text value ]
            , H.hr [ A.class "profile__business-card--input-line", class ] []
            ]

    else
        H.span [] []


fieldToString : T -> BusinessCardField -> String
fieldToString t field =
    case field of
        Name ->
            t "profile.businessCardFields.name"

        Title ->
            t "profile.businessCardFields.title"

        Location ->
            t "profile.businessCardFields.location"

        Phone ->
            t "profile.businessCardFields.phone"

        Email ->
            t "profile.businessCardFields.email"

        LinkedIn ->
            t "profile.businessCardFields.linkedIn"


userInfoBoxEditing2 : T -> Model -> User -> List (H.Html Msg)
userInfoBoxEditing2 t model user =
    [ H.div
        [ A.class "user-page__pic-container" ]
        [ H.span
            [ A.class "user-page__pic"
            , E.onClick (ChangeImage user)
            , E.onMouseEnter MouseEnterProfilePic
            , E.onMouseLeave MouseLeaveProfilePic
            ]
            [ if model.mouseOverUserImage then
                SvgIcons.upload

              else
                Common.picElementForUser user
            ]
        ]
    , H.div
        [ A.class "user-page__editing-name-details" ]
        [ H.h4 [ A.class "user-page__name" ]
            [ H.input
                [ A.placeholder <| t "profile.userInfoBox.nickNamePlaceholder"
                , A.value user.name
                , E.onInput ChangeNickname
                ]
                []
            ]
        , H.p
            [ A.class "user-page__work-details" ]
            [ H.input
                [ A.value user.title
                , E.onInput ChangeTitle
                , A.placeholder <| t "profile.userInfoBox.titlePlaceholder"
                ]
                []
            ]
        , location model user
        , H.p
            [ A.class "user-page__work-details" ]
            [ H.div [ A.class "profile__marker" ]
                [ H.i [ A.class "fa fa-book" ] [] ]
            , H.input
                [ A.value user.contributionStatus
                , E.onInput ChangeContributionStatus
                , A.placeholder <| t "profile.userInfoBox.contributionPlaceholder"
                ]
                []
            ]
        ]
    ]


userInfoBoxEditing : T -> Model -> User -> H.Html Msg
userInfoBoxEditing t model user =
    H.div
        []
        [ H.div
            [ A.class "row" ]
            [ H.div
                [ A.class "col-xs-12 user-page__editing-pic-and-name" ]
                (userInfoBoxEditing2 t model user)
            ]
        , userDescription t model user
        ]


userInfoBox : T -> Model -> User -> H.Html Msg
userInfoBox t model user =
    H.div
        [ A.class "col-md-6 user-page__user-info-box" ]
        [ H.div
            [ A.class "row" ]
            [ H.div
                [ A.class "col-xs-12" ]
                [ H.div
                    [ A.class "pull-left user-page__pic-container" ]
                    [ H.span [ A.class "user-page__pic" ] [ Common.picElementForUser user ] ]
                , H.div
                    [ A.class "pull-left" ]
                    [ H.h4 [ A.class "user-page__name" ]
                        [ if model.editing then
                            H.input
                                [ A.placeholder <| t "profile.userInfoBox.nickNamePlaceholder"
                                , A.value user.name
                                , E.onInput ChangeNickname
                                ]
                                []

                          else
                            H.text user.name
                        ]
                    , H.p
                        [ A.class "user-page__work-details" ]
                        [ if model.editing then
                            H.input
                                [ A.value user.title
                                , E.on "change" (Json.map ChangeTitle E.targetValue)
                                ]
                                []

                          else
                            H.text user.title
                        ]
                    , location model user
                    , H.div [ A.class "profile__detail" ] <| contributionStatus t user
                    ]
                ]
            ]
        , userDescription t model user
        , userIdForAdmins t user
        ]


location : Model -> User -> H.Html Msg
location model user =
    H.div
        [ A.classList
            [ ( "profile__location", True )
            , ( "user-page__editing-location", model.editing )
            ]
        ]
        [ H.img [ A.class "profile__location--marker", A.src "/static/lokaatio.svg" ] []
        , if model.editing then
            locationSelect user

          else
            H.span [ A.class "profile__location--text" ] [ H.text user.location ]
        ]


locationSelect : User -> H.Html Msg
locationSelect user =
    H.span
        [ A.class "user-page__location-select-container" ]
        [ H.select
            [ E.on "change" (Json.map ChangeLocation E.targetValue)
            , A.class "user-page__location-select"
            ]
            (List.map (optionPreselected user.location) ("" :: Config.finnishRegions))
        ]


userDescription : T -> Model -> User -> H.Html Msg
userDescription t model user =
    H.div
        [ A.class "row user-page__description" ]
        [ H.p [ A.class "col-xs-12" ]
            [ if model.editing then
                H.textarea
                    [ A.value user.description
                    , A.placeholder <| t "profile.userDescriptionPlaceholder"
                    , A.class "user-page__description-input"
                    , E.onInput ChangeDescription
                    ]
                    []

              else
                H.span [] <| PlainTextFormat.view user.description
            ]
        ]


userIdForAdmins : T -> User -> H.Html msg
userIdForAdmins t user =
    user.memberId
        |> Maybe.map (\id -> H.p [] [ H.text <| t "profile.userIdForAdmins" ++ String.fromInt id ])
        |> Maybe.withDefault (H.div [] [])


optionPreselected : String -> String -> H.Html msg
optionPreselected default value =
    if default == value then
        H.option [ A.selected True ] [ H.text value ]

    else
        H.option [] [ H.text value ]


contributionStatus : T -> User -> List (H.Html Msg)
contributionStatus t user =
    case user.contributionStatus of
        "" ->
            [ H.text "" ]

        _ ->
            [ H.div [ A.class "profile__marker" ]
                [ H.i [ A.class "fa fa-book" ] [] ]
            , H.span [] [ H.text user.contributionStatus ]
            ]
