module Profile.View exposing (editProfileBox, editProfileHeading, editProfileView, saveOrEdit, showProfileView, view, viewOwnProfileMaybe, viewUser)

import Common
import Html as H
import Html.Attributes as A
import Html.Events as E
import Json.Decode as Json
import Link
import ListAds
import Models.User exposing (User)
import Nav
import Profile.CareerStory as CareerStory
import Profile.Education as Education
import Profile.Expertise as Expertise
import Profile.Main exposing (BusinessCardField(..), Msg(..))
import Profile.Membership as Membership
import Profile.PublicInfo as PublicInfo
import Profile.RemoveProfile as RemoveProfile
import State.Config as Config
import State.Main as RootState
import State.Profile exposing (Model)
import Time
import Translation exposing (T)
import Util exposing (ViewMessage(..))


view : T -> Time.Zone -> Model -> RootState.Model -> H.Html (ViewMessage Msg)
view t timeZone model rootState =
    case model.user of
        Just user ->
            if model.editing then
                editProfileView t model user rootState

            else
                showProfileView t timeZone model user rootState

        Nothing ->
            H.div [] []


editProfileView : T -> Model -> User -> RootState.Model -> H.Html (ViewMessage Msg)
editProfileView t model user rootState =
    H.div
        []
        [ Common.profileTopRow t user model.editing Common.ProfileTab (saveOrEdit t user model.editing)
        , editProfileHeading t
        , Membership.infoEditing t user
        , H.map LocalViewMessage (PublicInfo.editing t model user)
        , H.map LocalViewMessage (Expertise.competences t model rootState.config user)
        , H.map LocalViewMessage (Education.editing t model rootState.config user)
        , H.map LocalViewMessage (CareerStory.view t model rootState.config user)
        , RemoveProfile.view t model
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


showProfileView : T -> Time.Zone -> Model -> User -> RootState.Model -> H.Html (ViewMessage Msg)
showProfileView t timeZone model user rootState =
    H.div [ A.class "user-page" ] <|
        [ Common.profileTopRow t user model.editing Common.ProfileTab (saveOrEdit t user model.editing)
        ]
            ++ viewOwnProfileMaybe t timeZone model True rootState.config


viewOwnProfileMaybe : T -> Time.Zone -> Model -> Bool -> Config.Model -> List (H.Html (ViewMessage Msg))
viewOwnProfileMaybe t timeZone model ownProfile config =
    model.user
        |> Maybe.map (viewUser t timeZone model ownProfile (H.div [] []) config model.user)
        |> Maybe.withDefault
            [ H.div
                [ A.class "container" ]
                [ H.div [ A.class "row user-page__section" ]
                    [ H.text <| t "profile.ownProfile.notLoggedIn" ]
                ]
            ]


viewUser : T -> Time.Zone -> Model -> Bool -> H.Html (ViewMessage Msg) -> Config.Model -> Maybe User -> User -> List (H.Html (ViewMessage Msg))
viewUser t timeZone model ownProfile contactUser config loggedInUserMaybe user =
    let
        viewAds =
            List.map (Util.localViewMap RemovalMessage) <|
                ListAds.viewAds t timeZone loggedInUserMaybe model.removal <|
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
            [ H.map LocalViewMessage (PublicInfo.userInfoBox t model user)
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
            List.map (H.map LocalViewMessage) (Expertise.view t model user config)
        ]
    , H.map LocalViewMessage <| Education.view t model config user
    , H.map LocalViewMessage <| CareerStory.view t model config user
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
