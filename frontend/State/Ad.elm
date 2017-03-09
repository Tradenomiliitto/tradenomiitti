module State.Ad exposing (..)

import State.Util exposing (SendingStatus(..))

type alias Model =
  { addingAnswer : Bool
  , answerText : String
  , sending : SendingStatus
  }

init : Model
init =
  { addingAnswer = False
  , answerText = ""
  , sending = NotSending
  }
