module State.Login exposing (..)


type alias Model =
    { username : String
    , password : String
    }


init : Model
init =
    { username = ""
    , password = ""
    }
