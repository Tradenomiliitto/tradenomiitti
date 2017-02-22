module State.Profile exposing (..)

import User

type alias Model =
  { user : Maybe User.User
  , editing : Bool
  }

init : Model
init =
  { user = Nothing
  , editing = False
  }
