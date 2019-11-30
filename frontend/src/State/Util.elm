module State.Util exposing (SendingStatus(..))


type SendingStatus
    = NotSending
    | Sending
    | FinishedSuccess String
    | FinishedFail
