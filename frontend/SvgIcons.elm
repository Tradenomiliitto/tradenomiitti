module SvgIcons exposing (..)

import Html as H
import Svg
import Svg.Attributes as SvgA

answers : H.Html msg
answers =
  Svg.svg
    [ SvgA.viewBox "0 0 64 60"
    ]
    [ Svg.g
      []
      [ Svg.path
        [ SvgA.d "M12.2,55.6c-0.1,0-0.2,0-0.4-0.1c-0.4-0.2-0.6-0.5-0.6-0.9V45h-9c-0.6,0-1-0.4-1-1V10.9c0-0.6,0.4-1,1-1h55c0.6,0,1,0.4,1,1V44c0,0.6-0.4,1-1,1H22.6l-9.7,10.3C12.7,55.5,12.5,55.6,12.2,55.6z M3.2,43h9c0.6,0,1,0.4,1,1v8.1l8.3-8.8c0.2-0.2,0.5-0.3,0.7-0.3h34V11.9h-53V43z"
        ]
        []
      , Svg.rect
        [ SvgA.x "11.8"
        , SvgA.y "20.9"
        , SvgA.width "35"
        , SvgA.height "2"
        ] []
      , Svg.rect
        [ SvgA.x "11.8"
        , SvgA.y "29.9"
        , SvgA.width "35"
        , SvgA.height "2"
        ] []
      , Svg.path
        [ SvgA.d "M61.8,35.9h-5v-2h4v-28h-53v4h-2v-5c0-0.6,0.4-1,1-1h55c0.6,0,1,0.4,1,1v30C62.8,35.5,62.4,35.9,61.8,35.9z"
        ] []
      ]
    ]
