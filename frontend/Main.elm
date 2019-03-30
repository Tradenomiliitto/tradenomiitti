port module Main exposing (Flags, HtmlId, Msg(..), animation, closeMenu, footerAppeared, init, logo, logoImage, main, navigation, navigationList, notImplementedYet, scrollTop, sendError, sendGaPageView, showAlert, subscriptions, unpackUpdateMessage, unpackViewMessage, update, verticalBar, view, viewLink, viewLinkInverse, viewPage, viewProfileLink)

import Ad
import Browser
import Browser.Navigation
import Common
import Config
import Contacts
import CreateAd
import Footer
import Home
import Html as H
import Html.Attributes as A
import Html.Events as E
import Http
import Info
import Json.Decode as Json
import ListAds
import ListUsers
import LoginNeeded
import Maybe.Extra as Maybe
import Nav exposing (..)
import PreformattedText
import Profile.Main as Profile
import Profile.View
import Settings
import State.Ad
import State.Contacts
import State.Home
import State.ListAds
import State.ListUsers
import State.Main exposing (..)
import State.Profile
import State.Settings
import State.User
import StaticContent
import Translation as T exposing (HasTranslations, T, Translations)
import Url
import User
import Util exposing (UpdateMessage(..), ViewMessage(..))


type alias HtmlId =
    String


{-| send True on splash screen, False otherwise
-}
port animation : ( HtmlId, Bool ) -> Cmd msg


{-| parameter tells whether to scroll
-}
port scrollTop : Bool -> Cmd msg


{-| parameter is path
-}
port sendGaPageView : String -> Cmd msg


port footerAppeared : (Bool -> msg) -> Sub msg


{-| parameter is ignored
-}
port closeMenu : Bool -> Cmd msg


port showAlert : String -> Cmd msg


type alias Flags =
    { translations : List ( String, String )
    , timeZoneOffset : Int
    }


main : Program Flags Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = UrlChange
        , onUrlRequest = ClickedLink
        }


init : Flags -> Url.Url -> Browser.Navigation.Key -> ( Model, Cmd Msg )
init { translations, timeZoneOffset } location key =
    let
        model =
            initState translations location key timeZoneOffset

        settingsCmd =
            unpackUpdateMessage SettingsMessage Settings.initTasks

        -- after the profile is loaded, an urlchange event is triggered
        profileCmd =
            unpackUpdateMessage ProfileMessage Profile.getMe

        configCmd =
            unpackUpdateMessage ConfigMessage Config.initTasks

        staticContentCmd =
            unpackUpdateMessage StaticContentMessage StaticContent.initTasks
    in
    ( model
    , Cmd.batch [ settingsCmd, profileCmd, configCmd, staticContentCmd ]
    )



-- UPDATE


type Msg
    = NewUrl Route
    | UrlChange Url.Url
    | ClickedLink Browser.UrlRequest
    | AllowProfileCreation
    | ToggleAcceptTerms
    | UserMessage User.Msg
    | ProfileMessage Profile.Msg
    | CreateAdMessage CreateAd.Msg
    | ListAdsMessage ListAds.Msg
    | ListUsersMessage ListUsers.Msg
    | AdMessage Ad.Msg
    | HomeMessage Home.Msg
    | SettingsMessage Settings.Msg
    | ConfigMessage Config.Msg
    | ContactsMessage Contacts.Msg
    | StaticContentMessage StaticContent.Msg
    | Error Http.Error
    | SendErrorResponse (Result Http.Error String)
    | NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update outerMsg model =
    let
        t =
            T.get model.translations

        tWith =
            T.getWith model.translations
    in
    case outerMsg of
        ClickedLink urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    if
                        String.contains "uloskirjautuminen" (Url.toString url)
                            || String.contains "kirjaudu" (Url.toString url)
                    then
                        ( model
                        , Browser.Navigation.load (Url.toString url)
                        )

                    else
                        ( model
                        , Cmd.none
                        )

                Browser.External url ->
                    ( model
                    , Browser.Navigation.load url
                    )

        NewUrl route ->
            ( { model | scrollTop = True }
            , Cmd.batch
                [ Browser.Navigation.pushUrl model.key (routeToPath route)
                , sendGaPageView (routeToPath route)
                , closeMenu True
                ]
            )

        UrlChange location ->
            let
                shouldScroll =
                    model.scrollTop

                route =
                    parseLocation model.profile.user location

                modelWithRoute =
                    { model | route = route, scrollTop = False }

                initWithUpdateMessage initModel mapper cmdIn =
                    if shouldScroll then
                        ( initModel
                        , unpackUpdateMessage mapper cmdIn
                        )

                    else
                        ( modelWithRoute
                        , Cmd.none
                        )

                ( newModel, innerCmd ) =
                    case route of
                        ShowAd adId ->
                            initWithUpdateMessage { modelWithRoute | ad = State.Ad.init }
                                AdMessage
                                (Ad.getAd adId)

                        Profile id ->
                            let
                                cleanProfile =
                                    State.Profile.init

                                initializedWithOldUser =
                                    { cleanProfile | user = modelWithRoute.profile.user }

                                initialModel =
                                    { modelWithRoute | profile = initializedWithOldUser }
                            in
                            initWithUpdateMessage initialModel
                                ProfileMessage
                                Profile.initTasks

                        ListAds ->
                            let
                                newListAds =
                                    State.ListAds.init modelWithRoute.settings
                            in
                            initWithUpdateMessage { modelWithRoute | listAds = newListAds }
                                ListAdsMessage
                                (ListAds.initTasks newListAds)

                        Home ->
                            let
                                newHome =
                                    State.Home.init modelWithRoute.settings

                                ( newNewModel, innerInnerCmd ) =
                                    initWithUpdateMessage { modelWithRoute | home = newHome }
                                        HomeMessage
                                        (Home.initTasks newHome)
                            in
                            ( newNewModel
                            , Cmd.batch [ innerInnerCmd, animation ( "home-intro-canvas", False ) ]
                            )

                        User userId ->
                            if Just userId == Maybe.map .id model.profile.user then
                                ( { model | route = Profile userId }
                                , Cmd.none
                                )

                            else
                                initWithUpdateMessage { modelWithRoute | user = State.User.init }
                                    UserMessage
                                    (User.initTasks userId)

                        ToProfile ->
                            case model.profile.user of
                                Just user ->
                                    ( { model | route = Profile user.id }
                                    , Browser.Navigation.replaceUrl model.key (routeToPath (Profile user.id))
                                    )

                                Nothing ->
                                    ( model
                                    , Browser.Navigation.pushUrl model.key (routeToPath (Nav.LoginNeeded << Just << Nav.routeToPath <| Nav.ToProfile))
                                    )

                        ListUsers ->
                            let
                                newListUsers =
                                    State.ListUsers.init

                                ( newNewModel, innerInnerCmd ) =
                                    initWithUpdateMessage { modelWithRoute | listUsers = newListUsers }
                                        ListUsersMessage
                                        (ListUsers.initTasks newListUsers)
                            in
                            ( newNewModel
                            , Cmd.batch [ innerInnerCmd, ListUsers.typeaheads newNewModel.listUsers model.config ]
                            )

                        LoginNeeded _ ->
                            ( modelWithRoute
                            , animation ( "login-needed-canvas", False )
                            )

                        Settings ->
                            initWithUpdateMessage { modelWithRoute | settings = State.Settings.init } SettingsMessage Settings.initTasks

                        Contacts ->
                            initWithUpdateMessage { modelWithRoute | contacts = State.Contacts.init } ContactsMessage Contacts.initTasks

                        _ ->
                            ( modelWithRoute, Cmd.none )

                needsLogin =
                    case ( route, Maybe.isJust model.profile.user, model.initialLoading ) of
                        ( CreateAd, False, False ) ->
                            True

                        ( ToProfile, False, False ) ->
                            True

                        ( Settings, False, False ) ->
                            True

                        _ ->
                            False

                newRoute =
                    if needsLogin then
                        routeToPath <| LoginNeeded (routeToPath route |> Just)

                    else
                        routeToPath route

                doConsentNeededAnimation =
                    if not model.initialLoading && model.needsConsent then
                        animation ( "consent-needed-canvas", True )

                    else
                        Cmd.none
            in
            if needsLogin then
                ( model
                , Browser.Navigation.replaceUrl model.key newRoute
                )

            else
                ( newModel
                , Cmd.batch
                    [ innerCmd
                    , scrollTop shouldScroll
                    , doConsentNeededAnimation
                    ]
                )

        UserMessage msg ->
            let
                ( userModel, innerCmd ) =
                    User.update msg model.user
            in
            ( { model | user = userModel }, unpackUpdateMessage UserMessage innerCmd )

        AllowProfileCreation ->
            let
                ( profileModel, innerCmd ) =
                    Profile.update Profile.AllowProfileCreation model.profile model.config

                newModel =
                    { model | profile = profileModel }
            in
            ( newModel
            , unpackUpdateMessage ProfileMessage innerCmd
            )

        ToggleAcceptTerms ->
            ( { model | acceptsTerms = not model.acceptsTerms }
            , Cmd.none
            )

        ProfileMessage msg ->
            let
                ( profileModel, innerCmd ) =
                    Profile.update msg model.profile model.config

                ( initialLoading, needsConsent ) =
                    case msg of
                        Profile.GetMe (Ok user) ->
                            ( False, not user.profileCreated )

                        Profile.GetMe (Err _) ->
                            ( False, False )

                        _ ->
                            ( model.initialLoading, model.needsConsent )

                -- We might want to do routing or other initalization based on the
                -- logged in profile, so redo that once we are first loaded
                redoNewUrlCmd =
                    if initialLoading /= model.initialLoading then
                        Browser.Navigation.replaceUrl model.key (routeToPath model.route)

                    else
                        Cmd.none
            in
            ( { model
                | profile = profileModel
                , initialLoading = initialLoading
                , needsConsent = needsConsent
              }
            , Cmd.batch
                [ unpackUpdateMessage ProfileMessage innerCmd
                , redoNewUrlCmd
                ]
            )

        CreateAdMessage msg ->
            let
                ( createAdModel, innerCmd ) =
                    CreateAd.update msg model.createAd
            in
            ( { model | createAd = createAdModel }
            , unpackUpdateMessage CreateAdMessage innerCmd
            )

        ListAdsMessage msg ->
            let
                ( listAdsModel, innerCmd ) =
                    ListAds.update msg model.listAds
            in
            ( { model | listAds = listAdsModel }
            , unpackUpdateMessage ListAdsMessage innerCmd
            )

        ListUsersMessage msg ->
            let
                ( listUsersModel, innerCmd ) =
                    ListUsers.update msg model.listUsers
            in
            ( { model | listUsers = listUsersModel }
            , unpackUpdateMessage ListUsersMessage innerCmd
            )

        AdMessage msg ->
            let
                ( adModel, innerCmd ) =
                    Ad.update msg model.ad
            in
            ( { model | ad = adModel }
            , unpackUpdateMessage AdMessage innerCmd
            )

        HomeMessage msg ->
            let
                ( homeModel, innerCmd ) =
                    Home.update msg model.home
            in
            ( { model | home = homeModel }
            , unpackUpdateMessage HomeMessage innerCmd
            )

        SettingsMessage msg ->
            let
                ( settingsModel, innerCmd ) =
                    Settings.update msg model.settings
            in
            ( { model | settings = settingsModel }
            , unpackUpdateMessage SettingsMessage innerCmd
            )

        ConfigMessage msg ->
            let
                ( configModel, innerCmd ) =
                    Config.update msg model.config
            in
            ( { model | config = configModel }
            , innerCmd
            )

        ContactsMessage msg ->
            let
                ( contactsModel, innerCmd ) =
                    Contacts.update msg model.contacts
            in
            ( { model | contacts = contactsModel }
            , innerCmd
            )

        StaticContentMessage msg ->
            let
                ( staticContentModel, innerCmd ) =
                    StaticContent.update msg model.staticContent
            in
            ( { model | staticContent = staticContentModel }
            , innerCmd
            )

        Error err ->
            let
                innerCmd =
                    case err of
                        Http.BadUrl str ->
                            sendError <| t "errors.badUrl" ++ str

                        Http.Timeout ->
                            showAlert <| t "errors.timeout"

                        Http.NetworkError ->
                            showAlert <| t "errors.networkError"

                        Http.BadPayload error { body } ->
                            sendError <| tWith "errors.badPayload" [ body, error ]

                        Http.BadStatus { status, body } ->
                            case status.code of
                                404 ->
                                    showAlert <| tWith "errors.badStatus" [ body ]

                                _ ->
                                    showAlert <| tWith "errors.codeToUserVisibleMessage" [ body ]
            in
            ( model
            , innerCmd
            )

        SendErrorResponse (Ok str) ->
            ( model
            , showAlert <| tWith "errors.codeToUserVisibleMessage" [ str ]
            )

        SendErrorResponse (Err err) ->
            ( model
            , showAlert <| tWith "errors.errorResponseFailure" [ Debug.toString err ]
            )

        NoOp ->
            ( model
            , Cmd.none
            )



--SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        footerListener =
            case model.route of
                ListAds ->
                    Sub.map ListAdsMessage (footerAppeared (always ListAds.FooterAppeared))

                ListUsers ->
                    Sub.map ListUsersMessage (footerAppeared (always ListUsers.FooterAppeared))

                _ ->
                    Sub.none

        typeaheadInUsersListener =
            case model.route of
                ListUsers ->
                    Sub.map ListUsersMessage ListUsers.subscriptions

                _ ->
                    Sub.none
    in
    Sub.batch
        [ Sub.map ProfileMessage (Profile.subscriptions model.profile)
        , footerListener
        , typeaheadInUsersListener
        ]



-- VIEW


view : Model -> Browser.Document Msg
view model =
    let
        t =
            T.get model.translations
    in
    { title = t "common.title"
    , body = [ viewHtml model t ]
    }


viewHtml : Model -> T -> H.Html Msg
viewHtml model t =
    let
        splashScreen =
            H.div
                [ A.class "splash-screen" ]
                [ logoImage (t "navigation.logoAlt") (t "main.splashScreen.logoWidth") ]

        askConsent =
            H.div
                [ A.class "splash-screen" ]
                [ H.canvas [ A.id "consent-needed-canvas", A.class "consent-needed__animation" ] []
                , H.div
                    [ A.class "consent-needed col-xs-12 col-md-5" ]
                    [ H.h1 [] [ H.text (t "main.consentNeeded.heading") ]
                    , H.p [] [ H.text (t "main.consentNeeded.content") ]
                    , H.div [ A.class "row consent-needed__actionable" ]
                        [ H.div
                            [ A.class "col-xs-12 col-sm-6" ]
                            [ H.label
                                []
                                [ H.input
                                    [ A.type_ "checkbox"
                                    , E.onClick ToggleAcceptTerms
                                    ]
                                    []
                                , H.span
                                    [ A.class "consent-needed__read-terms" ]
                                    [ H.text (t "main.consentNeeded.iAcceptThe")
                                    , H.a
                                        [ A.href "/kayttoehdot"
                                        , A.target "_blank"
                                        , A.class "consent-needed__read-terms-link"
                                        ]
                                        [ H.text (t "main.consentNeeded.terms") ]
                                    ]
                                ]
                            ]
                        , H.div
                            [ A.class "col-xs-12 col-sm-6" ]
                            [ H.button
                                [ A.class "btn btn-lg consent-needed__btn-inverse"
                                , E.onClick AllowProfileCreation
                                , A.disabled (not model.acceptsTerms)
                                ]
                                [ H.text (t "main.consentNeeded.createProfile") ]
                            ]
                        ]
                    ]
                ]

        mainUi =
            H.div [ A.class "page-layout" ]
                [ navigation model
                , viewPage model
                , Footer.view t NewUrl model.profile.user
                ]
    in
    if model.initialLoading then
        splashScreen

    else
        case ( model.needsConsent, model.route ) of
            ( True, Terms ) ->
                mainUi

            ( True, RegisterDescription ) ->
                mainUi

            ( True, _ ) ->
                askConsent

            _ ->
                mainUi



--TODO move navbar code to Nav.elm


navigation : Model -> H.Html Msg
navigation model =
    let
        t =
            T.get model.translations
    in
    H.nav
        [ A.class "navbar navbar-default navbar-fixed-top" ]
        [ H.div
            [ A.class "navbar-header" ]
            [ H.button
                [ A.class "navbar-toggle collapsed"
                , A.attribute "data-toggle" "collapse"
                , A.attribute "data-target" "#navigation"
                ]
                [ H.span [ A.class "sr-only" ] [ H.text (t "navigation.sr_open") ]
                , H.span [ A.class "icon-bar" ] []
                , H.span [ A.class "icon-bar" ] []
                , H.span [ A.class "icon-bar" ] []
                ]
            , logo t
            ]
        , H.div
            [ A.class "collapse navbar-collapse"
            , A.id "navigation"
            ]
            (navigationList model)
        ]


logo : T -> H.Html Msg
logo t =
    H.div
        [ A.class "navbar-brand" ]
        [ H.a
            [ A.id "logo"
            , A.href "/"
            , Common.linkAction Home NewUrl
            ]
            [ logoImage (t "navigation.logoAlt") (t "navigation.logoWidth")
            ]
        ]


logoImage : String -> String -> H.Html msg
logoImage alt width =
    H.img
        [ A.alt alt
        , A.src "/static/main_logo.svg"
        , A.class "logo-image"
        , A.style "width" width
        ]
        []


navigationList : Model -> List (H.Html Msg)
navigationList model =
    let
        t =
            T.get model.translations
    in
    [ H.ul
        [ A.class "nav navbar-nav nav-center" ]
        [ viewLink t ListUsers
        , verticalBar
        , viewLink t ListAds
        , viewLinkInverse t CreateAd
        ]
    , H.ul
        [ A.class "nav navbar-nav navbar-right" ]
        [ viewLink t Info
        , verticalBar
        , viewProfileLink t model
        ]
    ]


verticalBar : H.Html msg
verticalBar =
    H.li
        [ A.class <| "navbar__vertical-bar" ]
        [ H.div [] [] ]


viewLinkInverse : T -> Route -> H.Html Msg
viewLinkInverse t route =
    H.li
        [ A.class "navbar__inverse-button" ]
        [ Common.link t route NewUrl ]


viewLink : T -> Route -> H.Html Msg
viewLink t route =
    H.li
        []
        [ Common.link t route NewUrl ]


viewProfileLink : T -> Model -> H.Html Msg
viewProfileLink t model =
    let
        loggedIn =
            Maybe.isJust model.profile.user

        action =
            if loggedIn then
                [ E.custom
                    "click"
                    (Json.succeed
                        { message = NewUrl ToProfile
                        , stopPropagation = False
                        , preventDefault = True
                        }
                    )
                ]

            else
                []

        endpoint =
            if loggedIn then
                routeToPath ToProfile

            else
                ssoUrl model.rootUrl (routeToPath ToProfile |> Just)

        linkText =
            model.profile.user
                |> Maybe.map
                    (\u ->
                        if u.profileCreated then
                            u.name

                        else
                            t "main.profile"
                    )
                |> Maybe.withDefault (t "main.login")

        linkGraphic =
            model.profile.user
                |> Maybe.map
                    (\u ->
                        H.span
                            [ A.class "navbar__profile-pic" ]
                            [ Common.picElementForUser u ]
                    )
                |> Maybe.withDefault
                    (H.span
                        [ A.class "navbar__profile-lock glyphicon glyphicon-lock" ]
                        []
                    )
    in
    H.li
        []
        [ H.a
            (action
                ++ [ A.href endpoint
                   , A.classList [ ( "navbar__login-link", not loggedIn ) ]
                   ]
            )
            [ H.span
                [ A.classList
                    [ ( "navbar__profile-name", loggedIn )
                    ]
                ]
                [ H.text linkText
                ]
            , linkGraphic
            ]
        ]


viewPage : Model -> H.Html Msg
viewPage model =
    let
        t =
            T.get model.translations

        content =
            case model.route of
                User userId ->
                    unpackViewMessage UserMessage <| User.view t model.timeZone model.user model.profile.user model.config

                Profile userId ->
                    unpackViewMessage ProfileMessage <| Profile.View.view t model.timeZone model.profile model

                ToProfile ->
                    -- Never shown to user, used just for redirection
                    notImplementedYet t

                LoginNeeded route ->
                    LoginNeeded.view t <| ssoUrl model.rootUrl route

                CreateAd ->
                    H.map CreateAdMessage <| CreateAd.view t model.config model.createAd

                ListAds ->
                    unpackViewMessage ListAdsMessage <| ListAds.view t model.timeZone model.profile.user model.listAds model.config

                ShowAd adId ->
                    unpackViewMessage AdMessage <| Ad.view t model.ad adId model.profile.user model.rootUrl model.timeZone

                Home ->
                    unpackViewMessage HomeMessage <| Home.view t model.timeZone model.home model.profile.user

                ListUsers ->
                    unpackViewMessage ListUsersMessage <| ListUsers.view t model.listUsers model.config (Maybe.isJust model.profile.user)

                Terms ->
                    PreformattedText.view model.staticContent.terms

                RegisterDescription ->
                    PreformattedText.view model.staticContent.registerDescription

                Settings ->
                    unpackViewMessage SettingsMessage <| Settings.view t model.settings model.profile.user

                Info ->
                    Info.view model.staticContent.info

                Contacts ->
                    unpackViewMessage identity <| Contacts.view t model.timeZone model.contacts model.profile.user

                NotFound ->
                    notImplementedYet t
    in
    H.div
        [ A.class "app-content" ]
        [ content ]


unpackViewMessage : (msg -> Msg) -> H.Html (ViewMessage msg) -> H.Html Msg
unpackViewMessage func html =
    H.map
        (\message ->
            case message of
                Link route ->
                    NewUrl route

                LocalViewMessage mesg ->
                    func mesg
        )
        html


unpackUpdateMessage : (msg -> Msg) -> Cmd (UpdateMessage msg) -> Cmd Msg
unpackUpdateMessage mapper innerCmd =
    Cmd.map
        (\appMsg ->
            case appMsg of
                LocalUpdateMessage msg ->
                    mapper msg

                ApiError err ->
                    Error err

                Reroute route ->
                    NewUrl route

                UpdateUserPreferencesMessage msg ->
                    case msg of
                        Util.HideJobAds b ->
                            SettingsMessage (Settings.ChangeHideJobAds b)
        )
        innerCmd


notImplementedYet : T -> H.Html Msg
notImplementedYet t =
    H.div
        [ A.id "not-implemented" ]
        [ H.text <| t "main.notImplementedYet" ]


sendError : String -> Cmd Msg
sendError msg =
    Http.post "/api/virhe" (Http.stringBody "text/plain" msg) Json.string
        |> Http.send SendErrorResponse
