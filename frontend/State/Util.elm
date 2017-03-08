module State.Util exposing (..)

type SendingStatus = NotSending | Sending | FinishedSuccess String | FinishedFail
