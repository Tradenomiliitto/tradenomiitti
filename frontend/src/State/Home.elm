module State.Home exposing (Model, init)

import Removal
import State.ListAds
import State.ListUsers
import State.Settings


type alias Model =
    { listAds : State.ListAds.Model
    , listUsers : State.ListUsers.Model
    , createProfileClicked : Bool
    , removal : Removal.Model
    }


init : State.Settings.Model -> Model
init settings =
    { listAds = State.ListAds.init settings
    , listUsers = State.ListUsers.init
    , createProfileClicked = False
    , removal = Removal.init Removal.Ad
    }
