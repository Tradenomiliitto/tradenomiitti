module State.ListAds exposing (..)

import Models.Ad
import Removal


type Sort
    = CreatedDesc
    | CreatedAsc
    | AnswerCountDesc
    | AnswerCountAsc
    | NewestAnswerDesc


type alias Model =
    { ads : List Models.Ad.Ad
    , cursor : Int
    , selectedDomain : Maybe String
    , selectedPosition : Maybe String
    , selectedLocation : Maybe String
    , selectedChildAge : Maybe String
    , removal : Removal.Model
    , sort : Sort
    }


limit : Int
limit =
    10


init : Model
init =
    { ads = []
    , cursor = 0
    , selectedDomain = Nothing
    , selectedPosition = Nothing
    , selectedLocation = Nothing
    , selectedChildAge = Nothing
    , removal = Removal.init Removal.Ad
    , sort = CreatedDesc
    }
