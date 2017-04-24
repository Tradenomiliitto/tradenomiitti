module State.Config exposing (..)

type alias Model =
  { positionOptions : List String
  , domainOptions : List String
  , specialSkillOptionsJson : String
  }


init : Model
init =
  { positionOptions = []
  , domainOptions = []
  , specialSkillOptionsJson = "{}"
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
