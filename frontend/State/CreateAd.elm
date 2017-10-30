module State.CreateAd exposing (..)

import State.Util exposing (SendingStatus(..))


type alias Model =
    { heading : String
    , content : String
    , selectedDomain : Maybe String
    , selectedPosition : Maybe String
    , selectedLocation : Maybe String
    , isJobAd : Bool
    , sending : SendingStatus
    }


init : Model
init =
    { heading = ""
    , content = ""
    , selectedDomain = Nothing
    , selectedPosition = Nothing
    , selectedLocation = Nothing
    , isJobAd = False
    , sending = NotSending
    }
