module PreformattedText exposing (view)

import Html as H
import Html.Attributes as A


view : String -> List ( String, List String ) -> H.Html msg
view heading texts =
    H.div
        [ A.class "container" ]
        [ H.div
            [ A.class "row last-row" ]
            [ H.div
                [ A.class "col-sm-12" ]
              <|
                [ H.h1 [ A.class "preformatted__heading" ] [ H.text heading ]
                ]
                    ++ (List.indexedMap viewSingleSection texts |> List.concat)
            ]
        ]


viewSingleSection : Int -> ( String, List String ) -> List (H.Html msg)
viewSingleSection i ( heading, texts ) =
    [ H.h4 [ A.class "preformatted__section-heading" ] [ H.text <| toString (i + 1) ++ " " ++ heading ]
    ]
        ++ List.map (\t -> H.p [] [ H.text t ]) texts
