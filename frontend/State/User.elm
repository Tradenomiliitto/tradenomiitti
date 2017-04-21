module State.User exposing (..)

import Models.User exposing (User)
import Models.Ad exposing (Ad)

type alias Model =
  { user : Maybe User
  , ads : List Ad
  , viewAllAds : Bool
  , addingContact : Bool
  , addContactText : String
  }

init : Model
init =
  { user = Nothing
  , ads = []
  , viewAllAds = False
  , addingContact = False
  , addContactText = ""
  }
