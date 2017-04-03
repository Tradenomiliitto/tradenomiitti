module State.User exposing (..)

import Models.User exposing (User)
import Models.Ad exposing (Ad)

type alias Model =
  { user : Maybe User
  , ads : List Ad
  , addingContact : Bool
  , addContactText : String
  }

init : Model
init =
  { user = Nothing
  , ads = []
  , addingContact = False
  , addContactText = ""
  }
