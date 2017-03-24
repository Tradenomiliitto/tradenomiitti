module State.Settings exposing (..)

import Models.User exposing (Settings)
import State.Util exposing (SendingStatus(..))

type alias Model =
  { settings : Maybe Settings
  , sending : SendingStatus
  }


init : Model
init =
  { settings = Nothing
  , sending = NotSending
  }
