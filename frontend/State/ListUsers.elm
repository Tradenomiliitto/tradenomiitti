module State.ListUsers exposing (Model, Sort(..), init, limit)

import Models.User exposing (User)


type Sort
    = Recent
    | AlphaAsc
    | AlphaDesc


type alias Model =
    { users : List User
    , cursor : Int
    , receivedCount : Int
    , selectedDomain : Maybe String
    , selectedPosition : Maybe String
    , selectedLocation : Maybe String
    , selectedInstitute : String
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
    , receivedCount = 0
    , selectedDomain = Nothing
    , selectedPosition = Nothing
    , selectedLocation = Nothing
    , selectedInstitute = ""
    , selectedSpecialization = ""
    , selectedSkill = ""
    , sort = Recent
    }
