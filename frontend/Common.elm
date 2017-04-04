module Common exposing (..)

import Html as H
import Html.Attributes as A
import Html.Events as E
import Json.Decode as Json
import Link
import Models.User exposing (User)
import Nav exposing (Route, routeToPath, routeToString)
import SvgIcons
import Util exposing (ViewMessage(..))


authorInfo : User -> H.Html (ViewMessage msg)
authorInfo user =
  H.a
    [ Link.action (Nav.User user.id)]
    [ H.div
      []
      [ H.span [ A.class "author-info__pic" ] [ picElementForUser user ]
      , H.span
        [ A.class "author-info__info" ]
        [ H.span [ A.class "author-info__name"] [ H.text user.name ]
        , H.br [] []
        , H.span [ A.class "author-info__title"] [ H.text user.primaryPosition ]
        ]
      ]
    ]

picElementForUser : User -> H.Html msg
picElementForUser user =
  user.croppedPictureFileName
    |> Maybe.map (\url ->
                   H.img
                     [ A.src <| "/static/images/" ++ url
                     ]
                     []
                )
    |> Maybe.withDefault
      SvgIcons.userPicPlaceHolder

authorInfoWithLocation : User -> H.Html (ViewMessage msg)
authorInfoWithLocation user =
  H.a
    [ Link.action (Nav.User user.id)]
    [ H.div
      []
      [ H.span [ A.class "author-info__pic" ] [ picElementForUser user ]
      , H.span
        [ A.class "author-info__info" ]
        [ H.span [ A.class "author-info__name"] [ H.text user.name ]
        , H.br [] []
        , H.span [ A.class "author-info__title"] [ H.text user.primaryPosition ]
        , H.br [] []
        , showLocation user.location
        ]
      ]
    ]

link : Route -> (Route -> msg ) -> H.Html msg
link route toMsg =
  let
    action = linkAction route toMsg
  in
    H.a
      [ action
      , A.href (routeToPath route)
      ]
      [ H.text (routeToString route) ]


linkAction : Route -> (Route -> msg) -> H.Attribute msg
linkAction route toMsg =
  E.onWithOptions
    "click"
    { stopPropagation = False
    , preventDefault = True
    }
    (Json.succeed <| toMsg route)

showLocation : String -> H.Html msg
showLocation location =
  H.div [ A.class "profile__location" ]
    [ H.img [ A.class "profile__location--marker", A.src "/static/lokaatio.svg" ] []
    , H.span [ A.class "profile__location--text" ] [ H.text (location) ]
    ]
