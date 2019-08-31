module Profile.CareerStory exposing (view)

import Html as H
import Html.Attributes as A
import Html.Events as E
import Models.User exposing (User)
import PlainTextFormat
import Profile.Main exposing (Msg(..), Position(..))
import Profile.ViewUtil as ViewUtil
import State.Config as Config
import State.Profile exposing (Model)
import Translation exposing (T)


view : T -> Model -> Config.Model -> User -> H.Html Msg
view t model config user =
    let
        lastIndex =
            List.length user.careerStory - 1

        ifEditing el =
            if model.editing then
                [ el ]

            else
                []
    in
    H.div
        [ A.classList
            [ ( "career-story last-row", True )
            , ( "career-story--editing", model.editing )
            ]
        ]
        [ H.div
            [ A.class "container" ]
            [ H.div
                [ A.class "row" ]
              <|
                [ H.div
                    [ A.class "col-xs-12" ]
                  <|
                    [ H.h3
                        [ A.class "career-story-header" ]
                        [ H.text <| t "profile.careerStory.heading" ]
                    ]
                        ++ ifEditing (hint t)
                ]
                    ++ ifEditing
                        (addButton Top)
                    ++ List.indexedMap (\i step -> viewStoryStep t model config step i (modBy 2 (i + 1) == 0) (i == lastIndex)) user.careerStory
                    ++ ifEditing
                        (addButton Bottom)
            ]
        ]


addButton : Position -> H.Html Msg
addButton position =
    H.div
        [ A.class "col-xs-12 career-story__add-button-container" ]
        [ H.span
            [ A.class "career-story__add-button"
            , E.onClick <| AddCareerStoryStep position
            ]
            [ H.span [] [ H.text "+" ] ]
        ]


hint : T -> H.Html msg
hint t =
    H.p [ A.class "career-story__hint" ] [ H.text <| t "profile.careerStory.hint" ]


viewStoryStep t model config step index isEven isLast =
    H.div
        [ A.classList
            [ ( "col-sm-6 col-xs-11", True )
            , ( "col-sm-offset-6 col-xs-offset-1", isEven )
            , ( "career-story__step", True )
            , ( "career-story__step--left", not isEven )
            , ( "career-story__step--right", isEven )
            ]
        ]
    <|
        if model.editing then
            [ H.span [ A.class "removal" ]
                [ H.img
                    [ A.class "removal__icon"
                    , A.src "/static/close.svg"
                    , E.onClick <| RemoveCareerStoryStep index
                    ]
                    []
                ]
            , H.input
                [ A.placeholder <| t "profile.careerStory.titlePlaceholder"
                , A.value step.title
                , A.class "career-story__title-input"
                , E.onInput (ChangeCareerStoryTitle index)
                ]
                []
            , ViewUtil.select config.domainOptions
                (ChangeCareerStoryDomainSelect index)
                (Maybe.withDefault (t "profile.userDomains.selectDomain") step.domain)
                (t "profile.careerStory.selectDomainHint")
            , ViewUtil.select config.positionOptions
                (ChangeCareerStoryPositionSelect index)
                (Maybe.withDefault (t "profile.userPositions.selectPosition") step.position)
                (t "profile.careerStory.selectPositionHint")
            , H.textarea
                [ A.value step.description
                , A.class "career-story__description-input"
                , A.placeholder <| t "profile.careerStory.descriptionPlaceholder"
                , E.onInput (ChangeCareerStoryDescription index)
                ]
                []
            ]

        else
            [ H.div
                [ A.classList
                    [ ( "career-story__step-top", True )
                    , ( "career-story__step-top--left", not isEven )
                    , ( "career-story__step-top--right", isEven )
                    ]
                ]
                [ H.hr
                    [ A.classList
                        [ ( "career-story__step-top-ruler", True )
                        , ( "career-story__step-top-ruler--first", index == 0 )
                        ]
                    ]
                    []
                , H.span
                    [ A.classList
                        [ ( "career-story__step-top-ball", True )
                        , ( "career-story__step-top-ball--first", index == 0 )
                        , ( "career-story__step-top-ball--left", not isEven )
                        , ( "career-story__step-top-ball--right", isEven )
                        ]
                    ]
                    []
                ]
            , H.div
                [ A.classList
                    [ ( "career-story__step-content", True )
                    ]
                ]
                ((if isEven then
                    identity

                  else
                    List.reverse
                 )
                    [ H.div
                        [ A.classList
                            [ ( "career-story__step-border", True )
                            , ( "career-story__step-border--first", index == 0 )
                            , ( "career-story__step-border--left", not isEven )
                            , ( "career-story__step-border--right", isEven )
                            , ( "career-story__step-border--last", isLast )
                            ]
                        ]
                        [ H.div [] [] ]
                    , H.div
                        [ A.classList
                            [ ( "career-story__step-content--left", not isEven )
                            , ( "career-story__step-content--right", isEven )
                            ]
                        ]
                      <|
                        [ H.p [ A.class "career-story__step-heading" ] [ H.text step.title ]
                        ]
                            ++ Maybe.withDefault [] (Maybe.map (\text -> [ H.p [ A.class "career-story__step-domain" ] [ H.text text ] ]) step.domain)
                            ++ Maybe.withDefault [] (Maybe.map (\text -> [ H.p [ A.class "career-story__step-domain" ] [ H.text text ] ]) step.position)
                            ++ [ H.div [ A.class "career-story__step-description" ] (PlainTextFormat.view step.description) ]
                    ]
                )
            ]
