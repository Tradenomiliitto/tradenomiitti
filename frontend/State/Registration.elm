module State.Registration exposing (..)


type Status
    = NotLoaded
    | Success
    | Failure
    | NetworkError


type alias Model =
    { email : String
    , status : Status
    }


init : Model
init =
    { email = ""
    , status = NotLoaded
    }
