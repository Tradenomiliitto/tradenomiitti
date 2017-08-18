module State.InitPassword exposing (..)


type Status
    = NotLoaded
    | Success
    | Failure


type alias Model =
    { password : String
    , status : Status
    }


init : Model
init =
    { password = ""
    , status = NotLoaded
    }
