module Link exposing (..)

import Html as H
import Html.Attributes as A
import Html.Events as E
import Json.Decode as Json
import Nav exposing (Route, routeToPath, routeToString)
import Util exposing (ViewMessage(..))


link : String -> String -> Route -> H.Html (ViewMessage msg)
link title class route =
    H.a
        [ action route
        , A.href (routeToPath route)
        , A.class class
        ]
        [ H.text title ]


button : String -> String -> Route -> H.Html (ViewMessage msg)
button title class route =
    H.button
        [ E.onClick (Link route)
        , A.class class
        ]
        [ H.text title ]


action : Route -> H.Attribute (ViewMessage msg)
action route =
    E.onWithOptions
        "click"
        { stopPropagation = True -- Don't navigate twice in case of stacked links
        , preventDefault = True
        }
        (Json.succeed <| Link route)
