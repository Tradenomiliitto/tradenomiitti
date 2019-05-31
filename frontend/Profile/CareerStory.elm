module Profile.CareerStory exposing (editing, view)

import Html as H
import Html.Attributes as A
import Profile.Main exposing (Msg(..))
import State.Profile exposing (Model)
import Translation exposing (T)


editing =
    view


view : T -> Model -> H.Html Msg
view t model =
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
