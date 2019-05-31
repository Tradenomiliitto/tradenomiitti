module Profile.Education exposing (editing, educationsEditing, view)

import Common
import Html as H
import Html.Attributes as A
import Html.Events as E
import Models.User exposing (User)
import Profile.Main exposing (Msg(..))
import State.Config as Config
import State.Profile exposing (Model)
import Translation exposing (T)


editing : T -> Model -> Config.Model -> User -> H.Html Msg
editing =
    view


view : T -> Model -> Config.Model -> User -> H.Html Msg
view t model config user =
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
