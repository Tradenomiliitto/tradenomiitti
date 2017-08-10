module State.Login exposing (..)


type alias Model =
    { email : String
    , password : String
    }


init : Model
init =
    { email = ""
    , password = ""
    }
