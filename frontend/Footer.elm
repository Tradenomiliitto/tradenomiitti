module Footer exposing (..)

import Html as H
import Html.Attributes as A

view : H.Html msg
view =
  H.div
    [ A.class "footer" ]
    [ H.div
      [ A.class "container footer__content"]
      [ H.div [ A.class "row" ]
        [ H.div
          [ A.class "col-xs-12 col-sm-3" ]
          [ H.img
              [ A.src "/static/tral-logo_white.png"
              , A.class "footer__tral-logo"
              ] []
          ]
        , H.div
          [ A.class "col-xs-12 col-sm-3" ]
          [ H.p [] [ H.a [ A.href "/kayttoehdot" ] [ H.text "Palvelun käyttöehdot" ]]
          , H.p [] [ H.a [ A.href "/rekisteriseloste" ] [ H.text "Rekisteriseloste" ]]
          , H.p [] [ H.a [ A.href "http://tral.fi" ] [ H.text "tral.fi" ]]
          , H.p [] [ H.a [ A.href "http://liity.tral.fi/#liity" ] [ H.text "Liity jäseneksi" ]]
          ]
        , H.div
          [ A.class "col-xs-12 col-sm-4" ]
          [ ]
        ]
      ]
    ]
