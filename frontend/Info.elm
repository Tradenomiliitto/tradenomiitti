module Info exposing (view)

import Html as H
import Html.Attributes as A
import Markdown
import Maybe.Extra as Maybe
import State.StaticContent exposing (StaticContent, StaticContentBlock)


view : StaticContent -> H.Html msg
view staticContent =
    H.div
        [ A.class "container" ]
        [ H.div
            [ A.class "row last-row" ]
            [ H.div
                [ A.class "col-sm-12" ]
              <|
                [ H.h1
                    [ A.class "info__heading" ]
                    [ H.text staticContent.title ]
                ]
                    ++ List.map sectionView staticContent.contents
            ]
        ]


sectionView : StaticContentBlock -> H.Html msg
sectionView block =
    let
        heading =
            block.heading
                |> Maybe.toList
                |> List.map (\a -> H.h3 [] [ H.text a ])
    in
    H.div [] <|
        heading
            ++ [ Markdown.toHtml [] block.content ]
