module State.User exposing (Model, init)

import Models.Ad exposing (Ad)
import Models.User exposing (User)
import Removal


type alias Model =
    { user : Maybe User
    , ads : List Ad
    , viewAllAds : Bool
    , addingContact : Bool
    , addContactText : String
    , removal : Removal.Model
    }


init : Model
init =
    { user = Nothing
    , ads = []
    , viewAllAds = False
    , addingContact = False
    , addContactText = ""
    , removal = Removal.init Removal.Ad
    }
