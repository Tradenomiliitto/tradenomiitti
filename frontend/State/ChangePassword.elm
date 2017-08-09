module State.ChangePassword exposing (..)


type alias Model =
    { oldPassword : String
    , newPassword : String
    , newPassword2 : String
    }


init : Model
init =
    { oldPassword = ""
    , newPassword = ""
    , newPassword2 = ""
    }
