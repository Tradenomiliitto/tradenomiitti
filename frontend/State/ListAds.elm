module State.ListAds exposing (..)
import Ad

type alias Model =
  {
    ads: List Ad.Ad
  }

init : Model
init =
  { ads = [
  ] }