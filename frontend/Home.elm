module Home exposing (..)

import Html as H
import Html.Attributes as A

view : H.Html msg
view = 
  H.div 
    []
    [ introBox ]


introBox : H.Html msg
introBox =
  H.div
    [ A.class "home__introbox col-sm-6 col-sm-offset-3" ]
    [ H.h2 
      [ A.class "home__introbox--heading" ]
      [ H.text "Kohtaa tradenomi" ]
    , H.div
      [ A.class "home__introbox--content" ] 
      [ H.text "Tradenomiitti on tradenomien oma kohtaamispaikka, jossa jäsenet löytävät toisensa yhteisten aiheiden ympäriltä ja hyötyvät toistensa kokemuksista." ]
    , H.button
      [ A.class "btn btn-primary home__introbox--create-profile-button" ]
      [ H.text "luo profiili" ]
    ]