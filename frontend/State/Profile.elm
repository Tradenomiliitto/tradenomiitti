module State.Profile exposing (..)

import Models.Ad
import Models.User exposing (User)
import Removal

type alias Model =
  { user : Maybe User
  , ads : List Models.Ad.Ad
  , viewAllAds : Bool
  , editing : Bool
  , mouseOverUserImage : Bool
  , selectedInstitute : Maybe String
  , selectedDegree : Maybe String
  , selectedMajor : Maybe String
  , selectedSpecialization : Maybe String
  , removal : Removal.Model
  }

init : Model
init =
  { user = Nothing
  , ads = []
  , viewAllAds = False
  , editing = False
  , mouseOverUserImage = False
  , selectedInstitute = Nothing
  , selectedDegree = Nothing
  , selectedMajor = Nothing
  , selectedSpecialization = Nothing
  , removal = Removal.init
  }
