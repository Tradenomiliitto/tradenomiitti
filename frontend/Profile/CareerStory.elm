module Profile.CareerStory exposing (view)

import Html as H
import Html.Attributes as A
import Profile.Main exposing (Msg(..))
import State.Profile exposing (Model)
import Translation exposing (T)


view : T -> Model -> H.Html Msg
view t model =
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
            ]
        ]


hint : T -> H.Html msg
hint t =
    H.p [ A.class "user-page__career-story-hint" ] [ H.text <| t "profile.careerStory.hint" ]
