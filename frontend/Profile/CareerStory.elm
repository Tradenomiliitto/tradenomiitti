module Profile.CareerStory exposing (view)

import Html as H
import Html.Attributes as A
import Models.User exposing (User)
import PlainTextFormat
import Profile.Main exposing (Msg(..))
import Profile.ViewUtil as ViewUtil
import State.Config as Config
import State.Profile exposing (Model)
import Translation exposing (T)


view : T -> Model -> Config.Model -> User -> H.Html Msg
view t model config user =
    let
        ifEditing el =
            if model.editing then
                [ el ]

            else
                []
    in
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
              <|
                [ H.div
                    [ A.class "col-xs-12" ]
                  <|
                    [ H.h3
                        [ A.class "user-page__career-story-header" ]
                        [ H.text <| t "profile.careerStory.heading" ]
                    ]
                        ++ ifEditing (hint t)
                ]
                    ++ ifEditing
                        (H.div
                            [ A.class "col-xs-12 user-page__career-story-add-button-container" ]
                            [ H.span [ A.class "user-page__career-story-add-button" ]
                                [ H.span [] [ H.text "+" ] ]
                            ]
                        )
                    ++ List.indexedMap (\i step -> viewStoryStep t model config step (modBy 2 (i + 1) == 0)) user.careerStory
                    ++ ifEditing
                        (H.div
                            [ A.class "col-xs-12 user-page__career-story-add-button-container" ]
                            [ H.span [ A.class "user-page__career-story-add-button" ]
                                [ H.span [] [ H.text "+" ] ]
                            ]
                        )
            ]
        ]


hint : T -> H.Html msg
hint t =
    H.p [ A.class "user-page__career-story-hint" ] [ H.text <| t "profile.careerStory.hint" ]


viewStoryStep t model config step isEven =
    H.div
        [ A.classList
            [ ( "col-sm-6 col-xs-11", True )
            , ( "col-sm-offset-6 col-xs-offset-1", isEven )
            , ( "user-page__coreer-story-step--left", not isEven )
            , ( "user-page__coreer-story-step--right", isEven )
            ]
        ]
    <|
        if model.editing then
            [ H.input [ A.placeholder "moi", A.value step.title ] []
            , ViewUtil.select config.domainOptions
                (always NoOp)
                (t "profile.userDomains.selectDomain")
                (t "profile.userDomains.selectDomainHint")
            , ViewUtil.select config.positionOptions
                (always NoOp)
                (t "profile.userPositions.selectPosition")
                (t "profile.userPositions.selectPositionHint")
            , H.textarea
                [ A.value step.description
                , A.placeholder <| "hei"
                ]
                []
            ]

        else
            [ H.p [] [ H.text step.title ]
            ]
                ++ Maybe.withDefault [] (Maybe.map (\text -> [ H.p [] [ H.text text ] ]) step.domain)
                ++ Maybe.withDefault [] (Maybe.map (\text -> [ H.p [] [ H.text text ] ]) step.position)
                ++ PlainTextFormat.view step.description
