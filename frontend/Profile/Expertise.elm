module Profile.Expertise exposing (competences, view)

import Common
import Html as H
import Html.Attributes as A
import Html.Events as E
import Models.User exposing (User)
import Profile.Main exposing (BusinessCardField(..), Msg(..))
import Profile.ViewUtil as ViewUtil
import Skill
import State.Config as Config
import State.Profile exposing (Model)
import Translation exposing (T)


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
                (view t model user config)
            ]
        ]


view : T -> Model -> User -> Config.Model -> List (H.Html Msg)
view t model user config =
    [ userDomains t model user config
    , userPositions t model user config
    , userSkills t model user config
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
                    [ ViewUtil.select config.domainOptions
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
                    [ ViewUtil.select config.positionOptions
                        ChangePositionSelect
                        (t "profile.userPositions.selectPosition")
                        (t "profile.userPositions.selectPositionHint")
                    ]

                else
                    []
               )
        )
