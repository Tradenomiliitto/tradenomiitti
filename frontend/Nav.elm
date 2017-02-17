module Nav exposing (..)

import UrlParser as U exposing ((</>))
import Navigation

type Route = Home | ListUsers | ListAds | CreateAd | Info | Profile | User Int | NotFound

routeToPath : Route -> String
routeToPath route =
  case route of
    User userId ->
      "/user/" ++ (toString userId)
    Profile ->
      "/user/1"
    Home ->
      "/"
    Info ->
      "/info"
    NotFound ->
      "/notfound"
    ListUsers ->
      "/users"
    ListAds ->
      "/ads"
    CreateAd ->
      "/ad/create"


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
    [ U.map Home (U.s "")
    , U.map Info (U.s "info")
    , U.map User (U.s "user" </> U.int)
    ]
 