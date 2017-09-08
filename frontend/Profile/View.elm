module Profile.View exposing (..)

import Children
import Common
import Date
import Html as H
import Html.Attributes as A
import Html.Events as E
import Json.Decode as Json
import Link
import ListAds
import Models.User exposing (User)
import Nav
import PlainTextFormat
import Profile.Main exposing (BusinessCardField(..), Msg(..))
import Skill
import State.Config as Config
import State.Main as RootState
import State.Profile exposing (Model)
import SvgIcons
import Translation exposing (T)
import Util exposing (ViewMessage(..))
import WorkStatus


view : T -> Model -> RootState.Model -> H.Html (ViewMessage Msg)
view t model rootState =
    case model.user of
        Just user ->
            if model.editing then
                editProfileView t model user rootState
            else
                showProfileView t model user rootState

        Nothing ->
            H.div [] []


editProfileView : T -> Model -> User -> RootState.Model -> H.Html (ViewMessage Msg)
editProfileView t model user rootState =
    H.div
        []
        [ Common.profileTopRow t user model.editing Common.ProfileTab (saveOrEdit t user model.editing)
        , editProfileHeading t
        , membershipInfoEditing t user
        , H.map LocalViewMessage (publicInfoEditing t model user)
        , H.map LocalViewMessage (competences t model rootState.config user)
        , H.map LocalViewMessage (educationEditing t model rootState.config user)
        ]


saveOrEdit : T -> User -> Bool -> H.Html (ViewMessage Msg)
saveOrEdit t user editing =
    H.button
        [ A.class "btn btn-primary profile__top-row-edit-button"
        , E.onClick <|
            if editing then
                LocalViewMessage (Save user)
            else
                LocalViewMessage Edit
        , A.disabled <| user.name == ""
        , A.title <|
            if user.name == "" then
                t "profile.editProfile.nickNameMandatory"
            else
                ""
        ]
        [ H.text
            (if editing then
                t "profile.editProfile.buttonSave"
             else
                t "profile.editProfile.buttonEdit"
            )
        ]


editProfileHeading : T -> H.Html msg
editProfileHeading t =
    H.div [ A.class "container" ]
        [ H.div [ A.class "row" ]
            [ H.div
                [ A.class "profile__editing--heading col-sm-6 col-sm-offset-3" ]
                [ H.h2 [ A.class "profile__editing--heading--title" ] [ H.text <| t "profile.editProfile.heading" ]
                , H.p [ A.class "profile__editing--heading--content" ] [ H.text <| t "profile.editProfile.hint" ]
                ]
            ]
        ]


membershipInfoEditing : T -> User -> H.Html msg
membershipInfoEditing t user =
    H.div
        [ A.class "profile__editing--membership container" ]
        [ H.div
            [ A.class "row" ]
            [ membershipDataBoxEditing t user
            , membershipDataInfo t
            ]
        ]


membershipDataInfo : T -> H.Html msg
membershipDataInfo t =
    H.div
        [ A.class "profile__editing--membership--info col-md-6" ]
        [ H.p
            [ A.class "profile__editing--membership--info--text" ]
            [ H.text <| t "profile.membershipInfo.profileUsesMembershipInfo"
            , H.span [ A.class "profile__editing--bold" ]
                [ H.text <| t "profile.membershipInfo.notVisibleAsIs"
                ]
            ]
        , H.a
            [ A.href "https://mib.yhdistysavain.fi/jasensivut/"
            , A.target "_blank"
            ]
            [ H.button
                [ A.class "profile__editing--membership--info--button btn btn-primary" ]
                [ H.text <| t "profile.membershipInfo.buttonUpdateInfo"
                ]
            ]
        ]


publicInfoEditing : T -> Model -> User -> H.Html Msg
publicInfoEditing t model user =
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
            Just businessCard ->
                businessCardData t user businessCard

            Nothing ->
                H.div [] [ H.text <| t "profile.businessCard.notFound" ]
        ]


businessCardData : T -> User -> Models.User.BusinessCard -> H.Html Msg
businessCardData t user businessCard =
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
                            , A.value businessCard.name
                            , E.onInput (UpdateBusinessCard Profile.Main.Name)
                            ]
                            []
                        ]
                    , H.h5 []
                        [ H.input
                            [ A.class "profile__business-card--name-work--input"
                            , A.placeholder <| t "profile.businessCardFields.title"
                            , A.value businessCard.title
                            , E.onInput (UpdateBusinessCard Profile.Main.Title)
                            ]
                            []
                        ]
                    ]
                ]
            , H.div [ A.class "profile__business-card--data--contact" ]
                [ businessCardDataInput t businessCard Location
                , businessCardDataInput t businessCard Phone
                , businessCardDataInput t businessCard Email
                , businessCardDataInput t businessCard LinkedIn
                ]
            ]
        ]


businessCardView : T -> User -> Models.User.BusinessCard -> H.Html (ViewMessage msg)
businessCardView t user businessCard =
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
                        [ H.text businessCard.name ]
                    , H.h5 []
                        [ H.text businessCard.title ]
                    ]
                ]
            , H.div [ A.class "profile__business-card--data--contact" ]
                [ businessCardDataView businessCard Location
                , businessCardDataView businessCard Phone
                , businessCardDataView businessCard Email
                , businessCardDataView businessCard LinkedIn
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


showProfileView : T -> Model -> User -> RootState.Model -> H.Html (ViewMessage Msg)
showProfileView t model user rootState =
    H.div [ A.class "user-page" ] <|
        [ Common.profileTopRow t user model.editing Common.ProfileTab (saveOrEdit t user model.editing)
        ]
            ++ viewOwnProfileMaybe t model True rootState.config


competences : T -> Model -> Config.Model -> User -> H.Html Msg
competences t model config user =
    H.div
        [ A.class "container-fluid profile__editing--competences" ]
        [ H.div
            [ A.class "container"
            ]
            [ H.div [ A.class "profile__editing--competences--row row" ]
                [ H.div
                    [ A.class "profile__editing--competences--heading col-md-7" ]
                    [ H.h3
                        [ A.class "profile__editing--competences--heading--title" ]
                        [ H.text <| t "profile.competences.editHeading" ]
                    , H.p
                        [ A.class "profile__editing--competences--heading--text" ]
                        [ H.text <| t "profile.competences.hint"
                        , H.span [ A.class "profile__editing--bold" ] [ H.text <| t "profile.competences.visibleForEveryone" ]
                        ]
                    ]
                ]
            , H.div
                [ A.class "profile__editing--competences--row row" ]
                (userExpertise t model user config)
            ]
        ]


educationEditing : T -> Model -> Config.Model -> User -> H.Html Msg
educationEditing =
    viewEducations


userExpertise : T -> Model -> User -> Config.Model -> List (H.Html Msg)
userExpertise t model user config =
    [ userDomains t model user config
    , userPositions t model user config
    , userSkills t model user config
    ]


viewOwnProfileMaybe : T -> Model -> Bool -> Config.Model -> List (H.Html (ViewMessage Msg))
viewOwnProfileMaybe t model ownProfile config =
    model.user
        |> Maybe.map (viewUser t model ownProfile (H.div [] []) config model.user)
        |> Maybe.withDefault
            [ H.div
                [ A.class "container" ]
                [ H.div [ A.class "row user-page__section" ]
                    [ H.text <| t "profile.ownProfile.notLoggedIn" ]
                ]
            ]


viewEducations : T -> Model -> Config.Model -> User -> H.Html Msg
viewEducations t model config user =
    let
        educations =
            user.education
                |> List.indexedMap
                    (\index education ->
                        let
                            rowMaybe title valueMaybe =
                                valueMaybe
                                    |> Maybe.map
                                        (\value ->
                                            [ H.tr [] <|
                                                [ H.td [] [ H.text title ]
                                                , H.td [] [ H.text value ]
                                                ]
                                                    ++ (if model.editing then
                                                            [ H.td [] [] ]
                                                        else
                                                            []
                                                       )
                                            ]
                                        )
                                    |> Maybe.withDefault []
                        in
                        H.div
                            [ A.class "col-xs-12 col-sm-6" ]
                            [ H.table
                                [ A.class "user-page__education-details" ]
                                (List.concat
                                    [ [ H.tr [] <|
                                            [ H.td [] [ H.text <| t "profile.educations.degree" ]
                                            , H.td [] [ H.text education.degree ]
                                            ]
                                                ++ (if model.editing then
                                                        [ H.td
                                                            []
                                                            [ H.i
                                                                [ A.class "fa fa-remove user-page__education-details-remove"
                                                                , E.onClick (DeleteEducation index)
                                                                ]
                                                                []
                                                            ]
                                                        ]
                                                    else
                                                        []
                                                   )
                                      ]
                                    , rowMaybe (t "profile.educations.specialization") education.specialization
                                    ]
                                )
                            ]
                    )
                |> Common.chunk2
                |> List.map (\rowContents -> H.div [ A.class "row" ] rowContents)
    in
    H.div
        [ A.classList
            [ ( "user-page__education last-row", True )
            , ( "user-page__education--editing", model.editing )
            ]
        ]
        [ H.div
            [ A.class "container" ]
          <|
            [ H.div
                [ A.class "row" ]
                [ H.div
                    [ A.class "col-xs-12" ]
                    [ H.h3 [ A.class "user-page__education-header" ] [ H.text <| t "profile.educations.heading" ]
                    ]
                ]
            ]
                ++ educations
                ++ educationsEditing t model config
        ]


educationsEditing : T -> Model -> Config.Model -> List (H.Html Msg)
educationsEditing t model config =
    if model.editing then
        [ H.div
            [ A.class "row" ]
            [ H.div [ A.class "col-xs-5" ]
                [ H.p [] [ H.text <| t "profile.educationsEditing.hint" ]
                , Common.typeaheadInput "user-page__education-details-" (t "profile.educationsEditing.selectDegree") "education-degree"
                , Common.typeaheadInput "user-page__education-details-" (t "profile.educationsEditing.selectSpecialization") "education-specialization"
                , H.div
                    [ A.class "user-page__education-button-container" ]
                    [ model.selectedDegree
                        |> Maybe.map
                            (\degree ->
                                H.button
                                    [ A.class "btn btn-primary user-page__education-button"
                                    , E.onClick <| AddEducation degree
                                    ]
                                    [ H.text <| t "profile.educationsEditing.addEducation" ]
                            )
                        |> Maybe.withDefault
                            (H.button
                                [ A.class "btn btn-primary user-page__education-button"
                                , A.disabled True
                                , A.title <| t "profile.educationsEditing.degreeRequired"
                                ]
                                [ H.text <| t "profile.educationsEditing.addEducation" ]
                            )
                    ]
                ]
            ]
        ]
    else
        []


viewUser : T -> Model -> Bool -> H.Html (ViewMessage Msg) -> Config.Model -> Maybe User -> User -> List (H.Html (ViewMessage Msg))
viewUser t model ownProfile contactUser config loggedInUserMaybe user =
    let
        viewAds =
            List.map (Util.localViewMap RemovalMessage) <|
                ListAds.viewAds t loggedInUserMaybe model.removal <|
                    if model.viewAllAds then
                        model.ads
                    else
                        List.take 2 model.ads

        showMoreAds =
            -- if we are seeing all ads, don't show button
            -- if we don't have anything more to show, don't show button
            if model.viewAllAds || List.length model.ads <= 2 then
                []
            else
                [ H.button
                    [ A.class "btn user-page__activity-show-more"
                    , E.onClick <| LocalViewMessage ShowAll
                    ]
                    [ H.span [] [ H.text <| t "profile.viewUser.showAllActivity" ]
                    , H.i [ A.class "fa fa-chevron-down" ] []
                    ]
                ]
    in
    [ H.div
        [ A.class "container" ]
        [ H.div
            [ A.class "row user-page__section user-page__first-block" ]
            [ H.map LocalViewMessage (userInfoBox t model user)
            , if ownProfile then
                H.map LocalViewMessage (editProfileBox t user)
              else
                contactUser
            ]
        ]
    , H.div
        [ A.class "user-page__activity" ]
        [ H.div
            [ A.class "container" ]
          <|
            [ H.div
                [ A.class "row" ]
                [ H.div
                    [ A.class "col-sm-12" ]
                    [ H.h3 [ A.class "user-page__activity-header" ] [ H.text <| t "profile.viewUser.activity" ]
                    ]
                ]
            ]
                ++ viewAds
                ++ showMoreAds
        ]
    , H.div
        [ A.class "container" ]
        [ H.div
            [ A.class "row" ]
          <|
            List.map (H.map LocalViewMessage) (userExpertise t model user config)
        ]
    , H.map LocalViewMessage <| viewEducations t model config user
    ]


editProfileBox : T -> User -> H.Html Msg
editProfileBox t user =
    H.div
        [ A.class "col-md-6 user-page__edit-or-contact-user" ]
        [ H.p [] [ H.text <| t "profile.editProfileBox.hint" ]
        , H.button
            [ A.class "btn btn-primary profile__edit-button"
            , E.onClick Edit
            ]
            [ H.text <| t "profile.editProfileBox.editProfile" ]
        ]


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
        , editWorkStatus model t user
        , editChildrenStatus model t user
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
                    , workChildren t model.currentDate user
                    , H.div [ A.class "profile__detail" ] <| contributionStatus t user
                    ]
                ]
            ]
        , userDescription t model user
        , userIdForAdmins t user
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
        |> Maybe.map (\id -> H.p [] [ H.text <| t "profile.userIdForAdmins" ++ toString id ])
        |> Maybe.withDefault (H.div [] [])


location : Model -> User -> H.Html Msg
location model user =
    if (model.editing == False) && (user.location == "") then
        H.text ""
    else
        H.div
            [ A.classList
                [ ( "profile__detail", True )
                , ( "user-page__editing-location", model.editing )
                ]
            ]
            [ H.div [ A.class "profile__marker" ]
                [ H.i [ A.class "fa fa-map-marker" ] [] ]
            , if model.editing then
                locationSelect user
              else
                H.span [ A.class "profile__location--text" ] [ H.text user.location ]
            ]


editWorkStatus : Model -> T -> User -> H.Html Msg
editWorkStatus model t user =
    H.div
        [ A.classList
            [ ( "profile__detail", True )
            , ( "user-page__editing-location", model.editing )
            ]
        ]
        [ H.div [ A.class "profile__marker" ]
            [ H.i [ A.class "fa fa-briefcase" ] [] ]
        , workStatusSelect t user
        ]


editChildrenStatus : Model -> T -> User -> H.Html Msg
editChildrenStatus model t user =
    H.div
        [ A.classList
            [ ( "profile__detail", True )
            , ( "user-page__editing-location", model.editing )
            ]
        ]
        [ H.div [ A.class "profile__marker" ]
            [ H.i [ A.class "fa fa-child" ] [] ]
        , editChildren t model user
        ]


workStatusSelect : T -> User -> H.Html Msg
workStatusSelect t user =
    let
        makeOption =
            optionPreselected (user.workStatus |> Maybe.map (WorkStatus.toString t) |> Maybe.withDefault "")
    in
    H.span
        [ A.class "user-page__location-select-container" ]
        [ H.select
            [ E.on "change" (Json.map (ChangeWorkStatus << WorkStatus.fromString t) E.targetValue)
            , A.class "user-page__location-select"
            ]
            (List.map makeOption ("" :: List.map (WorkStatus.toString t) Config.workStatuses))
        ]


editChildren : T -> Model -> User -> H.Html Msg
editChildren t model user =
    H.div
        [ A.class "user-page__editing-familystatus" ]
        [ H.h4 [] [ H.text <| t "profile.childrenEditing.heading" ]
        , H.ul [ A.class "user-tags" ] <|
            (user.children
                |> Children.dates
                |> List.indexedMap
                    (\index date ->
                        H.li [ A.class "user-tags__tag" ]
                            [ H.span [ A.class "user-tags__tag-text" ] [ H.text date ]
                            , H.span [ E.onClick (DeleteChild index), A.class "user-tags__tag-remove" ] [ H.i [ A.class "fa fa-close" ] [] ]
                            ]
                    )
            )
                ++ addChild t model
        ]


addChild : T -> Model -> List (H.Html Msg)
addChild t model =
    [ H.div [ A.class "user-tags__tag" ]
        [ H.input
            [ A.placeholder <| t "profile.childrenEditing.placeholder.month"
            , A.class "user-page__add-child-input--month"
            , A.value model.birthMonth
            , A.size 2
            , A.type_ "number"
            , A.maxlength 2
            , E.onInput ChangeBirthMonth
            ]
            []
        , H.input
            [ A.placeholder <| t "profile.childrenEditing.placeholder.year"
            , A.class "user-page__add-child-input--year"
            , A.value model.birthYear
            , A.size 4
            , A.type_ "number"
            , A.maxlength 4
            , E.onInput ChangeBirthYear
            ]
            []
        , H.button
            [ E.onClick AddChild
            , A.class "user-page__add-child-button"
            , A.disabled <|
                case Profile.Main.validateBirthdate model of
                    Ok _ ->
                        False

                    Err _ ->
                        True
            ]
            [ H.i [ A.class "fa fa-plus" ] [] ]
        ]
    ]


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


workChildren : T -> Maybe Date.Date -> User -> H.Html Msg
workChildren t currentDate user =
    let
        workStatus =
            case user.workStatus of
                Just status ->
                    [ H.text <| WorkStatus.toString t status ++ ". " ]

                Nothing ->
                    []

        children =
            case user.children of
                [] ->
                    []

                status ->
                    [ H.text <| Children.asText t currentDate status ]
    in
    case workStatus ++ children of
        [] ->
            H.text ""

        status ->
            H.div [ A.class "profile__detail" ] <|
                [ H.div [ A.class "profile__marker" ]
                    [ H.i [ A.class "fa fa-home" ] [] ]
                ]
                    ++ status


optionPreselected : String -> String -> H.Html msg
optionPreselected default value =
    if default == value then
        H.option [ A.selected True ] [ H.text value ]
    else
        H.option [] [ H.text value ]


userDomains : T -> Model -> User -> Config.Model -> H.Html Msg
userDomains t model user config =
    H.div
        [ A.class "col-xs-12 col-sm-6 col-md-4 last-row"
        ]
        ([ H.h3 [ A.class "user-page__competences-header" ] [ H.text <| t "profile.userDomains.heading" ]
         ]
            ++ (if model.editing then
                    [ H.p [ A.class "profile__editing--competences--text" ] [ H.text <| t "profile.userDomains.question" ] ]
                else
                    [ H.p [ A.class "profile__editing--competences--text" ] [] ]
               )
            ++ List.indexedMap
                (\i x -> H.map (DomainSkillMessage i) <| Skill.view t model.editing x)
                user.domains
            ++ (if model.editing then
                    [ select config.domainOptions
                        ChangeDomainSelect
                        (t "profile.userDomains.selectDomain")
                        (t "profile.userDomains.selectDomainHint")
                    ]
                else
                    []
               )
        )


userSkills : T -> Model -> User -> Config.Model -> H.Html Msg
userSkills t model user config =
    H.div
        [ A.class "col-xs-12 col-sm-6 col-md-4 last-row"
        ]
    <|
        [ H.h3 [ A.class "user-page__competences-header" ] [ H.text <| t "profile.userSkills.heading" ]
        ]
            ++ (if model.editing then
                    [ H.p [ A.class "profile__editing--competences--text" ] [ H.text <| t "profile.userSkills.question" ] ]
                else
                    [ H.p [ A.class "profile__editing--competences--text" ] [] ]
               )
            ++ [ H.div []
                    -- wrapper div so that the search box doesn't get rerendered and lose it's state on JS side
                    (List.map
                        (\rowItems ->
                            H.div
                                [ A.class "row user-page__competences-special-skills-row" ]
                                (List.map
                                    (\skill ->
                                        H.div
                                            [ A.class "user-page__competences-special-skills col-xs-6" ]
                                        <|
                                            [ H.span
                                                [ A.class "user-page__competences-special-skills-text" ]
                                                [ H.text skill ]
                                            ]
                                                ++ (if model.editing then
                                                        [ H.i
                                                            [ A.class "fa fa-remove user-page__competences-special-skills-delete"
                                                            , E.onClick (DeleteSkill skill)
                                                            ]
                                                            []
                                                        ]
                                                    else
                                                        []
                                                   )
                                    )
                                    rowItems
                                )
                        )
                        (Common.chunk2 user.skills)
                    )
               ]
            ++ (if model.editing then
                    [ H.div
                        []
                        [ H.label
                            [ A.class "user-page__competence-select-label" ]
                            [ H.text <| t "profile.userSkills.addSkill" ]
                        , H.span
                            [ A.class "user-page__competence-select-container" ]
                            [ H.input
                                [ A.type_ "text"
                                , A.id "skills-input"
                                , A.class "user-page__competence-select"
                                , A.placeholder <| t "profile.userSkills.selectSkill"
                                ]
                                []
                            ]
                        ]
                    ]
                else
                    []
               )


userPositions : T -> Model -> User -> Config.Model -> H.Html Msg
userPositions t model user config =
    H.div
        [ A.class "col-xs-12 col-sm-6 col-md-4 last-row"
        ]
        ([ H.h3 [ A.class "user-page__competences-header" ] [ H.text <| t "profile.userPositions.heading" ]
         ]
            ++ (if model.editing then
                    [ H.p [ A.class "profile__editing--competences--text" ]
                        [ H.text <| t "profile.userPositions.question" ]
                    ]
                else
                    [ H.p [ A.class "profile__editing--competences--text" ] [] ]
               )
            ++ List.indexedMap
                (\i x -> H.map (PositionSkillMessage i) <| Skill.view t model.editing x)
                user.positions
            ++ (if model.editing then
                    [ select config.positionOptions
                        ChangePositionSelect
                        (t "profile.userPositions.selectPosition")
                        (t "profile.userPositions.selectPositionHint")
                    ]
                else
                    []
               )
        )


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


select : List String -> (String -> msg) -> String -> String -> H.Html msg
select options toEvent defaultOption heading =
    H.div
        []
        [ H.label
            [ A.class "user-page__competence-select-label" ]
            [ H.text heading ]
        , H.span
            [ A.class "user-page__competence-select-container" ]
            [ H.select
                [ E.on "change" (Json.map toEvent E.targetValue)
                , A.class "user-page__competence-select"
                ]
              <|
                H.option [] [ H.text defaultOption ]
                    :: List.map (\o -> H.option [] [ H.text o ]) options
            ]
        ]


membershipRegisterInfo : T -> Models.User.Extra -> H.Html msg
membershipRegisterInfo t extra =
    let
        row titleKey value =
            H.tr []
                [ H.td [] [ H.text <| t ("profile.membershipRegisterInfo." ++ titleKey) ]
                , H.td [] [ H.text value ]
                ]
    in
    H.table
        [ A.class "user-page__membership-info-definitions" ]
        [ row "firstName" extra.first_name
        , row "lastName" extra.last_name
        , row "email" extra.email
        , row "phone" extra.phone
        , row "division" extra.division
        , row "streetAddress" extra.streetAddress
        , row "postalCode" extra.postalCode
        , row "postalCity" extra.postalCity
        ]


membershipDataBoxEditing : T -> User -> H.Html msg
membershipDataBoxEditing t user =
    case user.extra of
        Just extra ->
            H.div
                [ A.class "col-md-6 profile__editing--membership--databox" ]
                [ H.h3 [ A.class "profile__editing--membership--databox--heading" ] [ H.text <| t "profile.membershipRegisterInfo.heading" ]
                , membershipRegisterInfo t extra
                ]

        Nothing ->
            H.div
                [ A.class "user-page__membership-info" ]
                [ H.h3 [ A.class "user-page__membership-info-heading" ] [ H.text <| t "profile.membershipRegisterInfo.missingData" ]
                ]
