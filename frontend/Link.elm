module Link exposing (..)
import Nav exposing (Route, routeToPath, routeToString)
import Html as H
import Html.Events as E
import Html.Attributes as A
import Json.Decode as Json

type AppMessage msg  = Link Route | LocalMessage msg


link : Route -> String -> H.Html (AppMessage msg)
link route title =
  let
    action =
      E.onWithOptions
        "click"
        { stopPropagation = False
        , preventDefault = True
        }
        (Json.succeed <| Link route)
  in
    H.a
      [ action
      , A.href (routeToPath route)
      ]
      [ H.text title ]