module Nav exposing (..)

import UrlParser exposing (Parser, (</>), int, oneOf, s, map)
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
  let route = UrlParser.parsePath routeParser location
  in 
    case route of 
      Just route -> route
      Nothing -> NotFound

routeParser : Parser (Route -> a) a
routeParser =
  oneOf 
    [ map Home (s "")
    , map Info (s "info")
    , map User (s "user" </> int)
    ]
 