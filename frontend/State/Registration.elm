module State.Registration exposing (..)


type Status
    = NotLoaded
    | Success
    | Failure
    | NetworkError


type alias Model =
    { email : String
    , consent : Bool
    , status : Status
    }


init : Model
init =
    { email = ""
    , consent = False
    , status = NotLoaded
    }
