module State.Profile exposing (..)

import State.Ad
import User

type alias Model =
  { user : Maybe User.User
  , ads : List State.Ad.Ad
  , editing : Bool
  , positionOptions : List String
  , domainOptions : List String
  , selectedPositionOption : String
  , selectedDomainOption : String
  }

init : Model
init =
  { user = Nothing
  , ads = []
  , editing = False
  , positionOptions = []
  , domainOptions = []
  , selectedDomainOption = ""
  , selectedPositionOption = ""
  }
