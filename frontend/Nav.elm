module Nav exposing (..)

import Navigation
import UrlParser as U exposing ((<?>), (</>))
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
  | LoginNeeded (Maybe String)
  | Terms
  | RegisterDescription
  | Settings

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
    LoginNeeded pathMaybe ->
      "/kirjautuminen-tarvitaan/" ++ (pathMaybe |> Maybe.map (\s -> "?seuraava=" ++ s) |> Maybe.withDefault "")
    Terms ->
      "/kayttoehdot"
    RegisterDescription ->
      "/rekisteriseloste"
    Settings ->
      "/asetukset"

routeToString : Route -> String
routeToString route =
  case route of
    User userId ->
      "Käyttäjä " ++ (toString userId)
    Profile ->
      "Oma Profiili"
    Home ->
      "Home"
    Info ->
      "Tietoa"
    NotFound ->
      "Ei löytynyt"
    ListUsers ->
      "Tradenomit"
    ListAds ->
      "Hakuilmoitukset"
    CreateAd ->
      "Jätä ilmoitus"
    ShowAd adId ->
      "Ilmoitus " ++ (toString adId)
    LoginNeeded _ ->
      "Kirjautuminen vaaditaan"
    Terms ->
      "Palvelun käyttöehdot"
    RegisterDescription ->
      "Rekisteriseloste"
    Settings ->
      "Asetukset"

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
    , U.map ListUsers (U.s "tradenomit")
    , U.map Home (U.s "")
    , U.map Info (U.s "tietoa")
    , U.map Profile (U.s "profiili")
    , U.map User (U.s "tradenomit" </> U.int)
    , U.map LoginNeeded (U.s "kirjautuminen-tarvitaan" <?> (U.stringParam "seuraava"))
    , U.map Terms (U.s "kayttoehdot")
    , U.map RegisterDescription (U.s "rekisteriseloste")
    , U.map Settings (U.s "asetukset")
    ]

ssoUrl : String -> Maybe String -> String
ssoUrl rootUrl maybePath =
  let
    loginUrl = rootUrl ++ "/kirjaudu" ++ (Maybe.map (\s -> "?path=" ++ s) maybePath |> Maybe.withDefault "")
    returnParameter = Window.encodeURIComponent loginUrl
  in
    "https://tunnistus.avoine.fi/sso-login/?service=tradenomiitti&return=" ++
      returnParameter
