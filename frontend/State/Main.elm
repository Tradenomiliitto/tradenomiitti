module State.Main exposing (..)

import Nav exposing (..)
import Navigation
import State.Profile as ProfileState
import State.CreateAd
import State.ListAds
import State.Ad
import User


type alias Model =
  { route : Route
  , rootUrl : String
  , user : User.Model
  , profile : ProfileState.Model
  , initialLoading : Bool
  , needsConsent : Bool
  , createAd : State.CreateAd.Model
  , listAds : State.ListAds.Model
  , ad : State.Ad.Model
  }


initState : Navigation.Location -> Model
initState location =
  { route = parseLocation location
  , rootUrl = location.origin
  , user = User.init
  , profile = ProfileState.init
  , initialLoading = True
  , needsConsent = True
  , createAd = State.CreateAd.init
  , listAds = State.ListAds.init
  , ad = State.Ad.init
  }
