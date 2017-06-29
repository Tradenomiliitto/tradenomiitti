module FormattedText exposing (view)

import Html as H
import Html.Attributes as A
import State.Config exposing (..)


view : String -> PreformattedText -> H.Html msg
view heading texts =
    H.div
        [ A.class "container" ]
        [ H.div
            [ A.class "row last-row" ]
            [ H.div
                [ A.class "col-sm-12" ]
              <|
                [ H.h1 [ A.class "info__heading" ] [ H.text heading ]
                ]
                    ++ (List.map singleElement texts |> List.concat)
            ]
        ]


singleElement : List String -> List (H.Html msg)
singleElement texts =
    [ H.h4 [] [ H.text (getHeading (List.head texts)) ]
    ]
        ++ List.map (\t -> H.p [] [ H.text t ]) (getTail (List.tail texts))


getHeading : Maybe String -> String
getHeading heading =
    case heading of
        Nothing ->
            ""

        Just string ->
            string


getTail : Maybe (List String) -> List String
getTail elements =
    case elements of
        Nothing ->
            []

        Just elementList ->
            elementList
