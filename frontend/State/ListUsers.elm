module State.ListUsers exposing (..)

import Models.User exposing (User)

type alias Model =
  { users : List User
  , cursor : Int
  , selectedDomain : Maybe String
  , selectedPosition : Maybe String
  , selectedLocation : Maybe String
  }

limit : Int
limit = 10

init : Model
init =
  { users = []
  , cursor = 0
  , selectedDomain = Nothing
  , selectedPosition = Nothing
  , selectedLocation = Nothing
  }
