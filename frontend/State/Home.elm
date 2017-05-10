module State.Home exposing (..)
import Removal
import State.ListAds
import State.ListUsers

type alias Model =
  { listAds : State.ListAds.Model
  , listUsers : State.ListUsers.Model
  , createProfileClicked : Bool
  , removal : Removal.Model
  }

init : Model
init =
  { listAds = State.ListAds.init
  , listUsers = State.ListUsers.init
  , createProfileClicked = False
  , removal = Removal.init Removal.Ad
  }
