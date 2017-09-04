module State.Login exposing (..)


type Status
    = NotLoaded
    | Failure
    | NetworkError


type alias Model =
    { email : String
    , password : String
    , status : Status
    }


init : Model
init =
    { email = ""
    , password = ""
    , status = NotLoaded
    }
