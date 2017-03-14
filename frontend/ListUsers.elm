module ListUsers exposing (..)

import Html as H
import Html.Attributes as A
import State.ListUsers exposing (..)

view : Model -> H.Html msg
view model =
  H.div
    []
    [ H.div
      [ A.class "container" ]
      [ H.div
        [ A.class "row" ]
        [ H.div
          [ A.class "col-sm-12" ]
          [ H.h3
            [ A.class "list-users__header" ]
            [ H.text "Selaa tradenomeja" ]
          ]
        ]
      ]
    , H.div
      [ A.class "list-users__list-background"]
      [ H.div
        [ A.class "container" ]
        [] -- TODO
      ]
    ]
