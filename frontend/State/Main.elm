module State.Main exposing (..)

import Nav exposing (..)
import Navigation
import State.Ad
import State.Config
import State.Contacts
import State.CreateAd
import State.Home
import State.ListAds
import State.ListUsers
import State.Profile as ProfileState
import State.Settings
import State.StaticContent
import State.User
import Translation exposing (Translations)


type alias Model =
    { route : Route
    , rootUrl : String
    , scrollTop : Bool
    , listUsers : State.ListUsers.Model
    , user : State.User.Model
    , profile : ProfileState.Model
    , initialLoading : Bool
    , needsConsent : Bool
    , acceptsTerms : Bool
    , createAd : State.CreateAd.Model
    , listAds : State.ListAds.Model
    , ad : State.Ad.Model
    , home : State.Home.Model
    , settings : State.Settings.Model
    , config : State.Config.Model
    , contacts : State.Contacts.Model
    , staticContent : State.StaticContent.Model
    , translations : Translations
    }


initState : List ( String, String ) -> Navigation.Location -> Model
initState translations location =
    { route = parseLocation location
    , rootUrl = location.origin
    , scrollTop = True -- initially start at top and init
    , user = State.User.init
    , listUsers = State.ListUsers.init
    , profile = ProfileState.init
    , initialLoading = True
    , needsConsent = True
    , acceptsTerms = False
    , createAd = State.CreateAd.init
    , listAds = State.ListAds.init
    , ad = State.Ad.init
    , home = State.Home.init
    , settings = State.Settings.init
    , config = State.Config.init
    , contacts = State.Contacts.init
    , staticContent = State.StaticContent.init
    , translations = Translation.fromList translations
    }
