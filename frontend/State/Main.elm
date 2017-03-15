module State.Main exposing (..)

import Nav exposing (..)
import Navigation
import State.Ad
import State.CreateAd
import State.ListAds
import State.Home
import State.ListUsers
import State.Profile as ProfileState
import State.User


type alias Model =
  { route : Route
  , rootUrl : String
  , listUsers : State.ListUsers.Model
  , user : State.User.Model
  , profile : ProfileState.Model
  , initialLoading : Bool
  , needsConsent : Bool
  , createAd : State.CreateAd.Model
  , listAds : State.ListAds.Model
  , ad : State.Ad.Model
  , home : State.Home.Model
  }


initState : Navigation.Location -> Model
initState location =
  { route = parseLocation location
  , rootUrl = location.origin
  , user = State.User.init
  , listUsers = State.ListUsers.init
  , profile = ProfileState.init
  , initialLoading = True
  , needsConsent = True
  , createAd = State.CreateAd.init
  , listAds = State.ListAds.init
  , ad = State.Ad.init
  , home = State.Home.init
  }
