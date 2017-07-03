module State.ListAds exposing (..)

import Models.Ad
import Removal


type alias Model =
    { ads : List Models.Ad.Ad
    , cursor : Int
    , selectedDomain : Maybe String
    , selectedPosition : Maybe String
    , selectedLocation : Maybe String
    , selectedSorting : Maybe String
    , removal : Removal.Model
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
    , selectedSorting = Just "created_at_desc"
    , removal = Removal.init Removal.Ad
    }
