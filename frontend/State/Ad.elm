module State.Ad exposing (..)

import Date
import State.Util exposing (SendingStatus(..))
import User

type alias Ad =
  { heading: String
  , content: String
  , answers: Answers
  , createdBy: User.User
  , createdAt: Date.Date
  }

type Answers = AnswerCount Int | AnswerList (List Answer)

type alias Answer =
  { content: String
  , createdBy: User.User
  , createdAt: Date.Date
  }

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
