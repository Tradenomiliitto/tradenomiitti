module Link exposing (..)

import Html as H
import Html.Attributes as A
import Html.Events as E
import Json.Decode as Json
import Nav exposing (Route, routeToPath, routeToString)
import Util exposing (ViewMessage(..))


link : Route -> String -> H.Html (ViewMessage msg)
link route title =
  H.a
    [ action route
    , A.href (routeToPath route)
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
    { stopPropagation = False
    , preventDefault = True
    }
    (Json.succeed <| Link route)
