module Nav exposing (..)

import Navigation
import Translation as T exposing (T)
import UrlParser as U exposing ((</>), (<?>))
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
    | Login
    | Registration
    | LoginNeeded (Maybe String)
    | Terms
    | RegisterDescription
    | Settings
    | Contacts
    | ChangePassword
    | RenewPassword
    | InitPassword (Maybe String)



-- TODO: Move URLs to translations


routeToPath : Route -> String
routeToPath route =
    case route of
        CreateAd ->
            "/ilmoitukset/uusi"

        ShowAd adId ->
            "/ilmoitukset/" ++ toString adId

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
            "/tradenomit/" ++ toString userId

        Login ->
            "/kirjaudu"

        LoginNeeded pathMaybe ->
            "/kirjautuminen-tarvitaan/" ++ (pathMaybe |> Maybe.map (\s -> "?seuraava=" ++ s) |> Maybe.withDefault "")

        Terms ->
            "/kayttoehdot"

        RegisterDescription ->
            "/rekisteriseloste"

        Registration ->
            "/register"

        Settings ->
            "/asetukset"

        Contacts ->
            "/kayntikortit"

        ChangePassword ->
            "/vaihdasalasana"

        RenewPassword ->
            "/muistasalasana"

        InitPassword tokenMaybe ->
            "/initpassword" ++ (tokenMaybe |> Maybe.map (\s -> "?token=" ++ s) |> Maybe.withDefault "")


routeToString : T -> Route -> String
routeToString t route =
    case route of
        User userId ->
            t "navigation.routeNames.user"
                |> T.replaceWith [ toString userId ]

        Profile ->
            t "navigation.routeNames.profile"

        Home ->
            t "navigation.routeNames.home"

        Info ->
            t "navigation.routeNames.info"

        NotFound ->
            t "navigation.routeNames.notFound"

        ListUsers ->
            t "navigation.routeNames.listUsers"

        ListAds ->
            t "navigation.routeNames.listAds"

        CreateAd ->
            t "navigation.routeNames.createAd"

        ShowAd adId ->
            t "navigation.routeNames.showAd"
                |> T.replaceWith [ toString adId ]

        Login ->
            t "navigation.routeNames.login"

        LoginNeeded _ ->
            t "navigation.routeNames.loginNeeded"

        Terms ->
            t "navigation.routeNames.terms"

        RegisterDescription ->
            t "navigation.routeNames.registerDescription"

        Registration ->
            t "navigation.routeNames.registration"

        Settings ->
            t "navigation.routeNames.settings"

        Contacts ->
            t "navigation.routeNames.contacts"

        ChangePassword ->
            t "navigation.routeNames.changePassword"

        RenewPassword ->
            t "navigation.routeNames.renewPassword"

        InitPassword _ ->
            t "navigation.routeNames.initPassword"


parseLocation : Navigation.Location -> Route
parseLocation location =
    let
        route =
            U.parsePath routeParser location
    in
    case route of
        Just route ->
            route

        Nothing ->
            NotFound


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
        , U.map Login (U.s "kirjaudu")
        , U.map Registration (U.s "register")
        , U.map LoginNeeded (U.s "kirjautuminen-tarvitaan" <?> U.stringParam "seuraava")
        , U.map Terms (U.s "kayttoehdot")
        , U.map RegisterDescription (U.s "rekisteriseloste")
        , U.map Settings (U.s "asetukset")
        , U.map Contacts (U.s "kayntikortit")
        , U.map ChangePassword (U.s "vaihdasalasana")
        , U.map RenewPassword (U.s "muistasalasana")
        , U.map InitPassword (U.s "initpassword" <?> U.stringParam "token")
        ]


ssoUrl : String -> Maybe String -> String
ssoUrl rootUrl maybePath =
    let
        loginBase =
            Window.encodeURIComponent (rootUrl ++ "/kirjaudu")

        redirectParam =
            Maybe.map (\s -> "&path=" ++ Window.encodeURIComponent s) maybePath |> Maybe.withDefault ""
    in
    "/kirjaudu"



--"/kirjaudu?base="
--    ++ loginBase
--    ++ redirectParam
