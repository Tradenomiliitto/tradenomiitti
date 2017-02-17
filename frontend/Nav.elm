module Nav exposing (..)

import UrlParser as U exposing ((</>))
import Navigation

type Route = CreateAd | ListAds | ListUsers | Home | Info | NotFound | Profile | User Int

routeToPath : Route -> String
routeToPath route =
  case route of
    CreateAd ->
      "/ad/create"
    ListAds ->
      "/ads"
    ListUsers ->
      "/users"
    Home ->
      "/"
    Info ->
      "/info"
    NotFound ->
      "/notfound"   
    Profile ->
      "/user/1"
    User userId ->
      "/user/" ++ (toString userId)


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
    [ U.map CreateAd (U.s "ad" </> U.s "create")
    , U.map ListAds (U.s "ads")
    , U.map ListUsers (U.s "users")
    , U.map Home (U.s "")
    , U.map Info (U.s "info")
    , U.map Profile (U.s "profile")
    , U.map User (U.s "user" </> U.int)
    ]
 