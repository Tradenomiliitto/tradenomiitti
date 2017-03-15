module State.ListUsers exposing (..)

import Models.User exposing (User)

type alias Model =
  { users : List User
  }

init : Model
init =
  { users = []
  }
