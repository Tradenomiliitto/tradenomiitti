module State.Profile exposing (..)

import Models.Ad
import Models.User exposing (User)

type alias Model =
  { user : Maybe User
  , ads : List Models.Ad.Ad
  , viewAllAds : Bool
  , editing : Bool
  , mouseOverUserImage : Bool
  }

init : Model
init =
  { user = Nothing
  , ads = []
  , viewAllAds = False
  , editing = False
  , mouseOverUserImage = False
  }
