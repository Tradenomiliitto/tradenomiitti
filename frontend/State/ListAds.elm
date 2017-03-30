module State.ListAds exposing (..)
import Models.Ad

type alias Model =
  { ads: List Models.Ad.Ad
  , cursor : Int
  }

limit : Int
limit = 10

init : Model
init =
  { ads = []
  , cursor = 0
  }
