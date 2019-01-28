module State.Main exposing (Model, initState)

import Browser
import Browser.Navigation
import Nav exposing (..)
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
import Url
import Util exposing (origin)


type alias Model =
    { route : Route
    , rootUrl : String
    , key : Browser.Navigation.Key
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


initState : List ( String, String ) -> Url.Url -> Browser.Navigation.Key -> Model
initState translations location key =
    let
        initialSettings =
            State.Settings.init
    in
    { route = parseLocation Nothing location
    , rootUrl = origin location
    , key = key
    , scrollTop = True -- initially start at top and init
    , user = State.User.init
    , listUsers = State.ListUsers.init
    , profile = ProfileState.init
    , initialLoading = True
    , needsConsent = True
    , acceptsTerms = False
    , createAd = State.CreateAd.init
    , listAds = State.ListAds.init initialSettings
    , ad = State.Ad.init
    , home = State.Home.init initialSettings
    , settings = initialSettings
    , config = State.Config.init
    , contacts = State.Contacts.init
    , staticContent = State.StaticContent.init
    , translations = Translation.fromList translations
    }
