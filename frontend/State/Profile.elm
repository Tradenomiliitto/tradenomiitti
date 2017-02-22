module State.Profile exposing (..)

import User

type alias Model =
  { user : Maybe User.User
  }
