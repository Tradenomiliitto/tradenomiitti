module State.RenewPassword exposing (..)


type Status
    = NotLoaded
    | Success
    | Failure


type alias Model =
    { email : String
    , status : Status
    }


init : Model
init =
    { email = ""
    , status = NotLoaded
    }
