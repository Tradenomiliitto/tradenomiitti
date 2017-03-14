module Nav exposing (..)

import Navigation
import UrlParser as U exposing ((</>))
import Window

type Route
  = CreateAd
  | ShowAd Int
  | ListAds
  | ListUsers
  | Home
  | Info
  | NotFound
  | Profile
  | User Int

routeToPath : Route -> String
routeToPath route =
  case route of
    CreateAd ->
      "/ilmoitukset/uusi"
    ShowAd adId ->
      "/ilmoitukset/" ++ (toString adId)
    ListAds ->
      "/ilmoitukset"
    ListUsers ->
      "/tradenomit"
    Home ->
      "/"
    Info ->
      "/tietoa"
    NotFound ->
      "/notfound"
    Profile ->
      "/profiili"
    User userId ->
      "/tradenomit/" ++ (toString userId)


parseLocation : Navigation.Location -> Route
parseLocation location =
  let route = U.parsePath routeParser location
  in
    case route of
      Just route -> route
      Nothing -> NotFound

routeParser : U.Parser (Route -> a) a
routeParser =
  U.oneOf
    [ U.map CreateAd (U.s "ilmoitukset" </> U.s "uusi")
    , U.map ShowAd (U.s "ilmoitukset" </> U.int)
    , U.map ListAds (U.s "ilmoitukset")
    , U.map ListUsers (U.s "ilmoitukset")
    , U.map Home (U.s "")
    , U.map Info (U.s "tietoa")
    , U.map Profile (U.s "profiili")
    , U.map User (U.s "tradenomit" </> U.int)
    ]


ssoUrl : String -> Route -> String
ssoUrl rootUrl route =
  let
    loginUrl = rootUrl ++ "/kirjaudu?path=" ++ (routeToPath route)
    returnParameter = Window.encodeURIComponent loginUrl
  in
    "https://tunnistus.avoine.fi/sso-login/?service=tradenomiitti&return=" ++
      returnParameter
