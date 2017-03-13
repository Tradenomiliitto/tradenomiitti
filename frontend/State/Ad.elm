module State.Ad exposing (..)

import State.Util exposing (SendingStatus(..))
import Models.Ad exposing (Ad)

type alias Model =
  { addingAnswer : Bool
  , answerText : String
  , sending : SendingStatus
  , ad : Maybe Ad
  }

init : Model
init =
  { addingAnswer = False
  , answerText = ""
  , sending = NotSending
  , ad = Nothing
  }
