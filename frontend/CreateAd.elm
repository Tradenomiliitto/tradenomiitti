module CreateAd exposing (..)

import Html as H
import Html.Attributes as A

type Msg = NoOp

view : H.Html Msg
view =
  H.div
  [ A.class "container"]
  [ H.div
    [ A.class "row" ]
    [ H.div
      [ A.class "col-xs-12 col-sm-7" ]
      [ H.h2
          []
          [ H.input
            [ A.placeholder "Otsikko" ]
            []
          ]
      , H.textarea
        [ A.placeholder "Kirjoita ytimekäs ilmoitus" ]
        []
      ]
    , H.div
      [ A.class "col-xs-12 col-sm-5" ]
      [ H.h3 [] [ H.text "Kenen toivot vastaavan?" ]
      , H.p [] [ H.text "Vastaajatarjokkaiden haku on tulossa pian" ]
      , H.p [] [ H.button
                [ A.class "btn btn-primary" ]
                [ H.text "Julkaise ilmoitus"]
               ]
      ]
    ]
  ]
