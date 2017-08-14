module State.User exposing (..)

import Date
import Models.Ad exposing (Ad)
import Models.User exposing (User)
import Removal


type alias Model =
    { user : Maybe User
    , ads : List Ad
    , date : Maybe Date.Date
    , viewAllAds : Bool
    , addingContact : Bool
    , addContactText : String
    , removal : Removal.Model
    }


init : Model
init =
    { user = Nothing
    , ads = []
    , date = Nothing
    , viewAllAds = False
    , addingContact = False
    , addContactText = ""
    , removal = Removal.init Removal.Ad
    }
