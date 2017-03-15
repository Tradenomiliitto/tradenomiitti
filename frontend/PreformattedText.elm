module PreformattedText exposing (view)

import Html as H
import Html.Attributes as A

view : String -> String -> H.Html msg
view heading text =
  H.div
    [ A.class "container" ]
    [ H.div
      [ A.class "row"]
      [ H.div
        [ A.class "col-sm-12" ]
        [ H.h3 [ A.class "preformatted__heading" ] [ H.text heading ]
        , H.pre [ A.class "preformatted__text" ] [ H.text text ]
        ]
      ]
    ]
