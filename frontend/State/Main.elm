module State.Main exposing (..)

import Nav exposing (..)
import Navigation
import State.Profile as ProfileState
import State.CreateAd
import User


type alias Model =
  { route : Route
  , rootUrl : String
  , user : User.Model
  , profile : ProfileState.Model
  , initialLoading : Bool
  , createAd : State.CreateAd.Model
  }


initState : Navigation.Location -> Model
initState location =
  { route = parseLocation location
  , rootUrl = location.origin
  , user = User.init
  , profile = ProfileState.init
  , initialLoading = True
  , createAd = State.CreateAd.init
  }
