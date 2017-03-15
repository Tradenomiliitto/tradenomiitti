module State.Home exposing (..)
import State.ListAds
import State.ListUsers

type alias Model =
  { listAds : State.ListAds.Model
  , listUsers : State.ListUsers.Model
  }

init : Model
init =
  { listAds = State.ListAds.init
  , listUsers = State.ListUsers.init
  }