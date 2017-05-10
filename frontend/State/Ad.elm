module State.Ad exposing (..)

import Models.Ad exposing (Ad)
import Removal
import State.Util exposing (SendingStatus(..))

type alias Model =
  { addingAnswer : Bool
  , answerText : String
  , sending : SendingStatus
  , ad : Maybe Ad
  , removal : Removal.Model
  }

init : Model
init =
  { addingAnswer = False
  , answerText = ""
  , sending = NotSending
  , ad = Nothing
  , removal = Removal.init Removal.Answer
  }
