module State.Profile exposing (..)

import User

type alias Model =
  { user : Maybe User.User
  , editing : Bool
  , positionOptions : List String
  , domainOptions : List String
  , selectedPositionOption : String
  , selectedDomainOption : String
  }

init : Model
init =
  { user = Nothing
  , editing = False
  , positionOptions = []
  , domainOptions = []
  , selectedDomainOption = ""
  , selectedPositionOption = ""
  }
