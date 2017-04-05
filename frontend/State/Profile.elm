module State.Profile exposing (..)

import Models.Ad
import Models.User exposing (User)

type alias Model =
  { user : Maybe User
  , ads : List Models.Ad.Ad
  , editing : Bool
  , positionOptions : List String
  , domainOptions : List String
  , mouseOverUserImage : Bool
  }

init : Model
init =
  { user = Nothing
  , ads = []
  , editing = False
  , positionOptions = []
  , domainOptions = []
  , mouseOverUserImage = False
  }
