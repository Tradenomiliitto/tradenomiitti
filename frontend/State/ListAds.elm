module State.ListAds exposing (..)
import State.Ad

type alias Model =
  { ads: List State.Ad.Ad
  }

init : Model
init =
  { ads = [] }
