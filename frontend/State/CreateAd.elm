module State.CreateAd exposing (..)


type SendingStatus = NotSending | Sending | FinishedSuccess String | FinishedFail

type alias Model =
  { heading : String
  , content : String
  , sending : SendingStatus
  }

init : Model
init =
  { heading = ""
  , content = ""
  , sending = NotSending
  }
