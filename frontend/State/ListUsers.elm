module State.ListUsers exposing (..)

import Models.User exposing (User)

type alias Model =
  { users : List User
  , cursor : Int
  }

limit : Int
limit = 10

init : Model
init =
  { users = []
  , cursor = 0
  }
