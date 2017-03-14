module State.ListAds exposing (..)
import Models.Ad

type alias Model =
  { ads: List Models.Ad.Ad
  }

init : Model
init =
  { ads = [] }
