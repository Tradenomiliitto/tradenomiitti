module State.Config exposing (..)

import Dict exposing (Dict)

type alias Model =
  { positionOptions : List String
  , domainOptions : List String
  , specialSkillOptions : CategoriedOptions
  , educationOptions : Education
  }

type alias CategoriedOptions = Dict String (List String)
type alias Education = Dict String CategoriedOptions


educationOptions : String -> Model -> CategoriedOptions
educationOptions type_ =
  .educationOptions >>
    Dict.get type_ >>
      Maybe.withDefault Dict.empty

institutes : Model -> CategoriedOptions
institutes = educationOptions "institute"

degrees : Model -> CategoriedOptions
degrees = educationOptions "degree"

majors : Model -> CategoriedOptions
majors = educationOptions "major"

specializations : Model -> CategoriedOptions
specializations = educationOptions "specialization"


init : Model
init =
  { positionOptions = []
  , domainOptions = []
  , specialSkillOptions = Dict.empty
  , educationOptions = Dict.empty
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
