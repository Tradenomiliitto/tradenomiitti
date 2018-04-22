module Nav exposing (..)

import Models.User
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
    | Profile Int
    | ToProfile
    | User Int
    | LoginNeeded (Maybe String)
    | Terms
    | RegisterDescription
    | Settings
    | Contacts



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

        Profile userId ->
            "/tradenomit/" ++ toString userId

        ToProfile ->
            "/profiili/"

        User userId ->
            "/tradenomit/" ++ toString userId

        LoginNeeded pathMaybe ->
            "/kirjautuminen-tarvitaan/" ++ (pathMaybe |> Maybe.map (\s -> "?seuraava=" ++ s) |> Maybe.withDefault "")

        Terms ->
            "/kayttoehdot"

        RegisterDescription ->
            "/rekisteriseloste"

        Settings ->
            "/asetukset"

        Contacts ->
            "/kayntikortit"


routeToString : T -> Route -> String
routeToString t route =
    case route of
        User userId ->
            t "navigation.routeNames.user"
                |> T.replaceWith [ toString userId ]

        Profile userId ->
            t "navigation.routeNames.profile"

        ToProfile ->
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

        LoginNeeded _ ->
            t "navigation.routeNames.loginNeeded"

        Terms ->
            t "navigation.routeNames.terms"

        RegisterDescription ->
            t "navigation.routeNames.registerDescription"

        Settings ->
            t "navigation.routeNames.settings"

        Contacts ->
            t "navigation.routeNames.contacts"


parseLocation : Maybe Models.User.User -> Navigation.Location -> Route
parseLocation user location =
    let
        route =
            U.parsePath (routeParser user) location
    in
    case route of
        Just route ->
            route

        Nothing ->
            NotFound


routeParser : Maybe Models.User.User -> U.Parser (Route -> a) a
routeParser user =
    U.oneOf
        [ U.map CreateAd (U.s "ilmoitukset" </> U.s "uusi")
        , U.map ShowAd (U.s "ilmoitukset" </> U.int)
        , U.map ListAds (U.s "ilmoitukset")
        , U.map ListUsers (U.s "tradenomit")
        , U.map Home (U.s "")
        , U.map Info (U.s "tietoa")
        , U.map ToProfile (U.s "profiili")
        , U.map
            (\id ->
                if Just id == Maybe.map .id user then
                    Profile id
                else
                    User id
            )
            (U.s "tradenomit" </> U.int)
        , U.map LoginNeeded (U.s "kirjautuminen-tarvitaan" <?> U.stringParam "seuraava")
        , U.map Terms (U.s "kayttoehdot")
        , U.map RegisterDescription (U.s "rekisteriseloste")
        , U.map Settings (U.s "asetukset")
        , U.map Contacts (U.s "kayntikortit")
        ]


ssoUrl : String -> Maybe String -> String
ssoUrl rootUrl maybePath =
    let
        loginBase =
            Window.encodeURIComponent (rootUrl ++ "/kirjaudu")

        redirectParam =
            Maybe.map (\s -> "&path=" ++ Window.encodeURIComponent s) maybePath |> Maybe.withDefault ""
    in
    "/kirjaudu?base="
        ++ loginBase
        ++ redirectParam
