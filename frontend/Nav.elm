module Nav exposing (..)

import UrlParser exposing (Parser, (</>), int, oneOf, s, map)
import Navigation

type Route = User Int | Home | Info | NotFound

routeToPath : Route -> String
routeToPath route =
  case route of
    User userId ->
      "/user/" ++ (toString userId)
    Home ->
      "/"
    Info ->
      "/info"
    NotFound ->
      "/notfound"



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
 