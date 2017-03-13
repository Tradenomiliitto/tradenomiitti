module Common exposing (..)

import Html as H
import Html.Attributes as A
import Models.User exposing (User)


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
