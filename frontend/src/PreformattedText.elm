module PreformattedText exposing (view)

import Html as H
import Html.Attributes as A
import Markdown
import Maybe.Extra as Maybe
import State.StaticContent exposing (StaticContent, StaticContentBlock)


view : StaticContent -> H.Html msg
view { title, contents } =
    H.div
        [ A.class "container" ]
        [ H.div
            [ A.class "row last-row" ]
            [ H.div
                [ A.class "col-sm-12" ]
              <|
                [ H.h1 [ A.class "preformatted__heading" ] [ H.text title ] ]
                    ++ (List.indexedMap viewSingleSection contents |> List.concat)
            ]
        ]


viewSingleSection : Int -> StaticContentBlock -> List (H.Html msg)
viewSingleSection i { heading, content } =
    let
        sectionHeading =
            heading
                |> Maybe.map (\text -> H.h4 [ A.class "preformatted__section-heading" ] [ H.text <| String.fromInt (i + 1) ++ " " ++ text ])
                |> Maybe.toList
    in
    sectionHeading
        ++ Markdown.toHtml Nothing content
