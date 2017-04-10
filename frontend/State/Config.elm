module State.Config exposing (..)

type alias Model =
  { positionOptions : List String
  , domainOptions : List String
  }


init : Model
init =
  { positionOptions = []
  , domainOptions = []
  }


finnishRegions : List String
finnishRegions =
  [ "Lappi"
  , "Pohjois-Pohjanmaa"
  , "Kainuu"
  , "Pohjois-Karjala"
  , "Pohjois-Savo"
  , "Etelä-Savo"
  , "Etelä-Karjala"
  , "Keski-Suomi"
  , "Etelä-Pohjanmaa"
  , "Pohjanmaa"
  , "Keski-Pohjanmaa"
  , "Pirkanmaa"
  , "Satakunta"
  , "Päijät-Häme"
  , "Kanta-Häme"
  , "Kymenlaakso"
  , "Uusimaa"
  , "Varsinais-Suomi"
  , "Ahvenanmaa"
  ]
