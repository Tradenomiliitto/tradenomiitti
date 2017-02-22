module State.Main exposing (..)

import Navigation
import Nav exposing (..)
import User


type alias Model =
  { route : Route
  , rootUrl : String
  , user : User.Model
  , profile : User.Model
  , initialLoading : Bool
  }


initState : Navigation.Location -> Model
initState location =
  { route = parseLocation location
  , rootUrl = location.origin
  , user = User.init
  , profile = { user = Nothing, spinning = True }
  , initialLoading = True
  }
