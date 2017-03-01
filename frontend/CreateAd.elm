module CreateAd exposing (..)

import Html as H
import Html.Attributes as A

type Msg = NoOp

view : H.Html Msg
view =
  H.div
  [ A.class "container"]
  [ H.div
    [ A.class "row create-ad" ]
    [ H.div
      [ A.class "col-xs-12 col-sm-7 create-ad__inputs" ]
      [ H.h2
          [ A.class "create-ad__heading-input" ]
          [ H.input
            [ A.placeholder "Otsikko" ]
            []
          ]
      , H.textarea
        [ A.placeholder "Kirjoita ytimekäs ilmoitus"
        , A.class "create-ad__textcontent"
        ]
        []
      ]
    , H.div
      [ A.class "col-xs-12 col-sm-5" ]
      [ H.h3
          [ A.class "create-ad__filters-heading"]
          [ H.text "Kenen toivot vastaavan?" ]
      , H.p [] [ H.text "Vastaajatarjokkaiden haku on tulossa pian" ]
      , H.p
        [ A.class "create-ad__submit-button" ]
        [ H.button
            [ A.class "btn btn-primary" ]
            [ H.text "Julkaise ilmoitus"]
        ]
      ]
    ]
  ]
