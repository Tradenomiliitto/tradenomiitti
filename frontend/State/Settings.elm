module State.Settings exposing (..)

import Models.User exposing (Settings)

type alias Model =
  { settings : Maybe Settings
  }


init : Model
init =
  { settings = Nothing
  }
