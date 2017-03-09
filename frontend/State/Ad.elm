module State.Ad exposing (..)

import State.Util exposing (SendingStatus(..))

type alias Model =
  { addingAnswer : Bool
  , answerText : String
  , sending : SendingStatus
  , adId : Maybe Int
  }

init : Model
init =
  { addingAnswer = False
  , answerText = ""
  , sending = NotSending
  , adId = Nothing
  }
