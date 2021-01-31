module Info exposing (view)

import Html as H
import Html.Attributes as A
import Markdown
import Maybe.Extra as Maybe
import State.StaticContent exposing (StaticContent, StaticContentBlock)


view : StaticContent -> H.Html msg
view staticContent =
    let
        contents =
            H.h1 [ A.class "info__heading" ] [ H.text staticContent.title ]
                :: List.concatMap sectionView staticContent.contents
    in
    H.div
        [ A.class "container" ]
        [ H.div
            [ A.class "row last-row" ]
            [ H.div [ A.class "col-sm-12" ] contents
            ]
        ]


sectionView : StaticContentBlock -> List (H.Html msg)
sectionView block =
    let
        heading =
            block.heading
                |> Maybe.toList
                |> List.map (\a -> H.h3 [] [ H.text a ])
    in
    heading
        ++ Markdown.toHtml Nothing block.content
