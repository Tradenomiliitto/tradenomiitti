module Common exposing (..)

import Html as H
import Html.Attributes as A
import Html.Events as E
import Json.Decode as Json
import Models.User exposing (User)
import Nav exposing (Route, routeToPath, routeToString)


authorInfo : User -> H.Html msg
authorInfo user =
  H.div
    []
    [ H.span [ A.class "author-info__pic" ] []
    , H.span
      [ A.class "author-info__info" ]
      [ H.span [ A.class "author-info__name"] [ H.text user.name ]
      , H.br [] []
      , H.span [ A.class "author-info__title"] [ H.text user.primaryPosition ]
      ]
    ]


link : Route -> (Route -> msg ) -> H.Html msg
link route toMsg =
  let
    action =
      E.onWithOptions
        "click"
        { stopPropagation = False
        , preventDefault = True
        }
        (Json.succeed <| toMsg route)
  in
    H.a
      [ action
      , A.href (routeToPath route)
      ]
      [ H.text (routeToString route) ]
