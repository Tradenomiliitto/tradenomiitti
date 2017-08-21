module State.Profile exposing (..)

import Date
import Models.Ad
import Models.User exposing (User)
import Removal


type alias Model =
    { user : Maybe User
    , ads : List Models.Ad.Ad
    , viewAllAds : Bool
    , editing : Bool
    , mouseOverUserImage : Bool
    , selectedDegree : Maybe String
    , selectedSpecialization : Maybe String
    , birthMonth : String
    , birthYear : String
    , removal : Removal.Model
    , currentDate : Maybe Date.Date
    }


init : Model
init =
    { user = Nothing
    , ads = []
    , viewAllAds = False
    , editing = False
    , mouseOverUserImage = False
    , selectedDegree = Nothing
    , selectedSpecialization = Nothing
    , birthMonth = ""
    , birthYear = ""
    , removal = Removal.init Removal.Ad
    , currentDate = Nothing
    }
