module Profile.ViewUtil exposing (select)

import Html as H
import Html.Attributes as A
import Html.Events as E
import Json.Decode as Json


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
