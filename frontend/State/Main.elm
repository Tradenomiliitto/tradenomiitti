module State.Main exposing (..)

import Nav exposing (..)
import Navigation
import State.Profile as ProfileState
import User


type alias Model =
  { route : Route
  , rootUrl : String
  , user : User.Model
  , profile : ProfileState.Model
  , initialLoading : Bool
  }


initState : Navigation.Location -> Model
initState location =
  { route = parseLocation location
  , rootUrl = location.origin
  , user = User.init
  , profile = { user = Nothing }
  , initialLoading = True
  }
