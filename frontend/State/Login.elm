module State.Login exposing (..)


type Status
    = NotLoaded
    | Success
    | Failure


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
