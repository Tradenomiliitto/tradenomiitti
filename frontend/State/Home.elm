module State.Home exposing (..)
import State.ListAds

type alias Model =
  { listAds : State.ListAds.Model
  }

init : Model
init =
  { listAds = State.ListAds.init }