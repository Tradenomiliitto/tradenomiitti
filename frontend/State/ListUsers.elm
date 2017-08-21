module State.ListUsers exposing (..)

import Models.User exposing (User)


type Sort
    = Recent
    | AlphaAsc
    | AlphaDesc


type alias Model =
    { users : List User
    , cursor : Int
    , selectedDomain : Maybe String
    , selectedPosition : Maybe String
    , selectedLocation : Maybe String
    , selectedSpecialization : String
    , selectedSkill : String
    , sort : Sort
    }


limit : Int
limit =
    10


init : Model
init =
    { users = []
    , cursor = 0
    , selectedDomain = Nothing
    , selectedPosition = Nothing
    , selectedLocation = Nothing
    , selectedSpecialization = ""
    , selectedSkill = ""
    , sort = Recent
    }
