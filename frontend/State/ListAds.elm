module State.ListAds exposing (..)
import User

type alias Model =
  {
    ads: List User.Ad
  }

init : Model
init =
  { ads = [] }