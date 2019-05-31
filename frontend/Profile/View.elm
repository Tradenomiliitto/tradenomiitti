module Profile.View exposing (careerStoryEditing, competences, editProfileBox, editProfileHeading, editProfileView, educationEditing, educationsEditing, saveOrEdit, select, showProfileView, userDomains, userExpertise, userPositions, userSkills, view, viewCareerStory, viewEducations, viewOwnProfileMaybe, viewUser)

import Common
import Html as H
import Html.Attributes as A
import Html.Events as E
import Json.Decode as Json
import Link
import ListAds
import Models.User exposing (User)
import Nav
import Profile.Main exposing (BusinessCardField(..), Msg(..))
import Profile.Membership as Membership
import Profile.PublicInfo as PublicInfo
import Skill
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
        , H.map LocalViewMessage (competences t model rootState.config user)
        , H.map LocalViewMessage (educationEditing t model rootState.config user)
        , H.map LocalViewMessage (careerStoryEditing t model)
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
                                            [ H.td [] [ H.text <| t "profile.educations.institute" ]
                                            , H.td [] [ H.text education.institute ]
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
                                    , rowMaybe (t "profile.educations.degree") education.degree
                                    , rowMaybe (t "profile.educations.major") education.major
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
            [ ( "user-page__education", True )
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
                [ H.p [ A.class "user-page__education-hint" ] [ H.text <| t "profile.educationsEditing.hint" ]
                , Common.typeaheadInput "user-page__education-details-" (t "profile.educationsEditing.selectInstitute") "education-institute"
                , Common.typeaheadInput "user-page__education-details-" (t "profile.educationsEditing.selectDegree") "education-degree"
                , Common.typeaheadInput "user-page__education-details-" (t "profile.educationsEditing.selectMajor") "education-major"
                , Common.typeaheadInput "user-page__education-details-" (t "profile.educationsEditing.selectSpecialization") "education-specialization"
                , H.div
                    [ A.class "user-page__education-button-container" ]
                    [ model.selectedInstitute
                        |> Maybe.map
                            (\institute ->
                                H.button
                                    [ A.class "btn btn-primary user-page__education-button"
                                    , E.onClick <| AddEducation institute
                                    ]
                                    [ H.text <| t "profile.educationsEditing.addEducation" ]
                            )
                        |> Maybe.withDefault
                            (H.button
                                [ A.class "btn btn-primary user-page__education-button"
                                , A.disabled True
                                , A.title <| t "profile.educationsEditing.instituteRequired"
                                ]
                                [ H.text <| t "profile.educationsEditing.addEducation" ]
                            )
                    ]
                ]
            ]
        ]

    else
        []


careerStoryEditing =
    viewCareerStory


viewCareerStory : T -> Model -> H.Html Msg
viewCareerStory t model =
    H.div
        [ A.classList
            [ ( "user-page__career-story last-row", True )
            , ( "user-page__career-story--editing", model.editing )
            ]
        ]
        [ H.div
            [ A.class "container" ]
            [ H.div
                [ A.class "row" ]
                [ H.div
                    [ A.class "col-xs-12" ]
                    ([ H.h3 [ A.class "user-page__career-story-header" ] [ H.text <| t "profile.careerStory.heading" ]
                     ]
                        ++ (if model.editing then
                                [ H.p [ A.class "user-page__career-story-hint" ] [ H.text <| t "profile.careerStory.hint" ] ]

                            else
                                []
                           )
                    )
                ]
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
            List.map (H.map LocalViewMessage) (userExpertise t model user config)
        ]
    , H.map LocalViewMessage <| viewEducations t model config user
    , H.map LocalViewMessage <| viewCareerStory t model
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
