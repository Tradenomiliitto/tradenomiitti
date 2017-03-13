module Home exposing (..)

import Html as H

view : H.Html msg
view = 
  H.div 
    []
    [ introBox ]


introBox : H.Html msg
introBox =
  H.div
    []
    [ H.h3 [] [H.text "Kohtaa tradenomi"]
    , H.div [] [H.text "Tradenomiitti on tradenomien oma kohtaamispaikka, jossa jäsenet löytävät toisensa yhteisten aiheiden ympäriltä ja hyötyvät toistensa kokemuksista"]
    ]