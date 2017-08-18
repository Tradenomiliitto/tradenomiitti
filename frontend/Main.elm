port module Main exposing (..)

import Ad
import ChangePassword
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
import InitPassword
import Json.Decode as Json
import ListAds
import ListUsers
import Login
import LoginNeeded
import Maybe.Extra as Maybe
import Nav exposing (..)
import Navigation
import PreformattedText
import Profile.Main as Profile
import Profile.View
import Registration
import Settings
import State.Ad
import State.ChangePassword
import State.Contacts
import State.Home
import State.InitPassword
import State.ListAds
import State.ListUsers
import State.Main exposing (..)
import State.Profile
import State.Settings
import State.User
import StaticContent
import Translation as T exposing (HasTranslations, T, Translations)
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
    }


main : Program Flags Model Msg
main =
    Navigation.programWithFlags UrlChange
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


init : Flags -> Navigation.Location -> ( Model, Cmd Msg )
init { translations } location =
    let
        model =
            initState translations location

        -- after the profile is loaded, an urlchange event is triggered
        profileCmd =
            unpackUpdateMessage ProfileMessage Profile.getMe

        configCmd =
            unpackUpdateMessage ConfigMessage Config.initTasks

        staticContentCmd =
            unpackUpdateMessage StaticContentMessage StaticContent.initTasks
    in
    model ! [ profileCmd, configCmd, staticContentCmd ]



-- UPDATE


type Msg
    = NewUrl Route
    | UrlChange Navigation.Location
    | AllowProfileCreation
    | ToggleAcceptTerms
    | UserMessage User.Msg
    | ProfileMessage Profile.Msg
    | CreateAdMessage CreateAd.Msg
    | ChangePasswordMessage ChangePassword.Msg
    | LoginMessage Login.Msg
    | RegistrationMessage Registration.Msg
    | InitPasswordMessage InitPassword.Msg
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
update msg model =
    let
        t =
            T.get model.translations

        tWith =
            T.getWith model.translations
    in
    case msg of
        NewUrl route ->
            { model | scrollTop = True }
                ! [ Navigation.newUrl (routeToPath route)
                  , sendGaPageView (routeToPath route)
                  , closeMenu True
                  ]

        UrlChange location ->
            let
                shouldScroll =
                    model.scrollTop

                route =
                    parseLocation location

                modelWithRoute =
                    { model | route = route, scrollTop = False }

                initWithUpdateMessage initModel mapper cmd =
                    if shouldScroll then
                        initModel ! [ unpackUpdateMessage mapper cmd ]
                    else
                        modelWithRoute ! []

                ( newModel, cmd ) =
                    case route of
                        ShowAd adId ->
                            initWithUpdateMessage { modelWithRoute | ad = State.Ad.init }
                                AdMessage
                                (Ad.getAd adId)

                        Profile ->
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
                                    State.ListAds.init
                            in
                            initWithUpdateMessage { modelWithRoute | listAds = newListAds }
                                ListAdsMessage
                                (ListAds.initTasks newListAds)

                        Home ->
                            let
                                newHome =
                                    State.Home.init

                                ( newModel, cmd ) =
                                    initWithUpdateMessage { modelWithRoute | home = newHome }
                                        HomeMessage
                                        (Home.initTasks newHome)
                            in
                            newModel ! [ cmd, animation ( "home-intro-canvas", False ) ]

                        User userId ->
                            if Just userId == Maybe.map .id model.profile.user then
                                { model | route = Profile } ! [ Navigation.modifyUrl (routeToPath Profile) ]
                            else
                                initWithUpdateMessage { modelWithRoute | user = State.User.init }
                                    UserMessage
                                    (User.initTasks userId)

                        ListUsers ->
                            let
                                newListUsers =
                                    State.ListUsers.init

                                ( newModel, cmd ) =
                                    initWithUpdateMessage { modelWithRoute | listUsers = newListUsers }
                                        ListUsersMessage
                                        (ListUsers.initTasks newListUsers)
                            in
                            newModel ! [ cmd, ListUsers.typeaheads newModel.listUsers model.config ]

                        LoginNeeded _ ->
                            modelWithRoute ! [ animation ( "login-needed-canvas", False ) ]

                        Settings ->
                            initWithUpdateMessage { modelWithRoute | settings = State.Settings.init } SettingsMessage Settings.initTasks

                        Contacts ->
                            initWithUpdateMessage { modelWithRoute | contacts = State.Contacts.init } ContactsMessage Contacts.initTasks

                        ChangePassword ->
                            initWithUpdateMessage { modelWithRoute | changePassword = State.ChangePassword.init } ChangePasswordMessage Cmd.none

                        InitPassword ->
                            initWithUpdateMessage { modelWithRoute | initPassword = State.InitPassword.init } InitPasswordMessage Cmd.none

                        newRoute ->
                            ( modelWithRoute, Cmd.none )

                needsLogin =
                    case ( route, Maybe.isJust model.profile.user, model.initialLoading ) of
                        ( CreateAd, False, False ) ->
                            True

                        ( Profile, False, False ) ->
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
                model ! [ Navigation.modifyUrl newRoute ]
            else
                newModel
                    ! [ cmd
                      , scrollTop shouldScroll
                      , doConsentNeededAnimation
                      ]

        UserMessage msg ->
            let
                ( userModel, cmd ) =
                    User.update msg model.user
            in
            ( { model | user = userModel }, unpackUpdateMessage UserMessage cmd )

        AllowProfileCreation ->
            let
                ( profileModel, cmd ) =
                    Profile.update Profile.AllowProfileCreation model.profile model.config

                newModel =
                    { model | profile = profileModel }
            in
            newModel ! [ unpackUpdateMessage ProfileMessage cmd ]

        ToggleAcceptTerms ->
            { model | acceptsTerms = not model.acceptsTerms } ! []

        ProfileMessage msg ->
            let
                ( profileModel, cmd ) =
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
                        Navigation.modifyUrl (routeToPath model.route)
                    else
                        Cmd.none
            in
            { model
                | profile = profileModel
                , initialLoading = initialLoading
                , needsConsent = needsConsent
            }
                ! [ unpackUpdateMessage ProfileMessage cmd
                  , redoNewUrlCmd
                  ]

        CreateAdMessage msg ->
            let
                ( createAdModel, cmd ) =
                    CreateAd.update msg model.createAd
            in
            { model | createAd = createAdModel }
                ! [ unpackUpdateMessage CreateAdMessage cmd ]

        LoginMessage msg ->
            let
                ( loginModel, cmd ) =
                    Login.update msg model.login
            in
            { model | login = loginModel }
                ! [ unpackUpdateMessage LoginMessage cmd ]

        RegistrationMessage msg ->
            let
                ( registrationModel, cmd ) =
                    Registration.update msg model.registration
            in
            { model | registration = registrationModel }
                ! [ unpackUpdateMessage RegistrationMessage cmd ]

        ListAdsMessage msg ->
            let
                ( listAdsModel, cmd ) =
                    ListAds.update msg model.listAds
            in
            { model | listAds = listAdsModel } ! [ unpackUpdateMessage ListAdsMessage cmd ]

        ListUsersMessage msg ->
            let
                ( listUsersModel, cmd ) =
                    ListUsers.update msg model.listUsers
            in
            { model | listUsers = listUsersModel } ! [ unpackUpdateMessage ListUsersMessage cmd ]

        AdMessage msg ->
            let
                ( adModel, cmd ) =
                    Ad.update msg model.ad
            in
            { model | ad = adModel } ! [ unpackUpdateMessage AdMessage cmd ]

        HomeMessage msg ->
            let
                ( homeModel, cmd ) =
                    Home.update msg model.home
            in
            { model | home = homeModel } ! [ unpackUpdateMessage HomeMessage cmd ]

        SettingsMessage msg ->
            let
                ( settingsModel, cmd ) =
                    Settings.update msg model.settings
            in
            { model | settings = settingsModel } ! [ unpackUpdateMessage SettingsMessage cmd ]

        ConfigMessage msg ->
            let
                ( configModel, cmd ) =
                    Config.update msg model.config
            in
            { model | config = configModel } ! [ cmd ]

        ContactsMessage msg ->
            let
                ( contactsModel, cmd ) =
                    Contacts.update msg model.contacts
            in
            { model | contacts = contactsModel } ! [ cmd ]

        ChangePasswordMessage msg ->
            let
                ( changePasswordModel, cmd ) =
                    ChangePassword.update msg model.changePassword
            in
            { model | changePassword = changePasswordModel } ! [ unpackUpdateMessage ChangePasswordMessage cmd ]

        InitPasswordMessage msg ->
            let
                ( initPasswordModel, cmd ) =
                    InitPassword.update msg model.initPassword
            in
            { model | initPassword = initPasswordModel } ! [ unpackUpdateMessage InitPasswordMessage cmd ]

        StaticContentMessage msg ->
            let
                ( staticContentModel, cmd ) =
                    StaticContent.update msg model.staticContent
            in
            { model | staticContent = staticContentModel } ! [ cmd ]

        Error err ->
            let
                cmd =
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
            model ! [ cmd ]

        SendErrorResponse (Ok str) ->
            model ! [ showAlert <| tWith "errors.codeToUserVisibleMessage" [ str ] ]

        SendErrorResponse (Err err) ->
            model ! [ showAlert <| tWith "errors.errorResponseFailure" [ toString err ] ]

        NoOp ->
            model ! []



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


view : Model -> H.Html Msg
view model =
    let
        t =
            T.get model.translations

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
            [ H.span [] [ H.text "MiBiT" ]
            ]
        ]


logoImage : String -> String -> H.Html msg
logoImage alt width =
    H.img
        [ A.alt alt
        , A.src "/static/main_logo_duo.png"
        , A.class "logo-image"
        , A.style [ ( "width", width ) ]
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
                [ E.onWithOptions
                    "click"
                    { stopPropagation = False
                    , preventDefault = True
                    }
                    (Json.succeed <| NewUrl Profile)
                ]
            else
                []

        endpoint =
            if loggedIn then
                routeToPath Profile
            else
                ssoUrl model.rootUrl (routeToPath Profile |> Just)

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
                    unpackViewMessage UserMessage <| User.view t model.user model.profile.user model.config

                Profile ->
                    unpackViewMessage ProfileMessage <| Profile.View.view t model.profile model

                LoginNeeded route ->
                    LoginNeeded.view t <| ssoUrl model.rootUrl route

                CreateAd ->
                    H.map CreateAdMessage <| CreateAd.view t model.config model.createAd

                ListAds ->
                    unpackViewMessage ListAdsMessage <| ListAds.view t model.profile.user model.listAds model.config

                ShowAd adId ->
                    unpackViewMessage AdMessage <| Ad.view t model.ad adId model.profile.user model.rootUrl

                Home ->
                    unpackViewMessage HomeMessage <| Home.view t model.home model.profile.user

                Login ->
                    H.map LoginMessage <| Login.view t model.login

                ListUsers ->
                    unpackViewMessage ListUsersMessage <| ListUsers.view t model.listUsers model.config (Maybe.isJust model.profile.user)

                Terms ->
                    PreformattedText.view model.staticContent.terms

                RegisterDescription ->
                    PreformattedText.view model.staticContent.registerDescription

                Registration ->
                    H.map RegistrationMessage <| Registration.view t model.registration

                Settings ->
                    unpackViewMessage SettingsMessage <| Settings.view t model.settings model.profile.user

                Info ->
                    Info.view model.staticContent.info

                Contacts ->
                    unpackViewMessage identity <| Contacts.view t model.contacts model.profile.user

                ChangePassword ->
                    unpackViewMessage ChangePasswordMessage <| ChangePassword.view t model.changePassword model.profile.user

                InitPassword ->
                    H.map InitPasswordMessage <| InitPassword.view t model.initPassword

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
unpackUpdateMessage mapper cmd =
    Cmd.map
        (\appMsg ->
            case appMsg of
                LocalUpdateMessage msg ->
                    mapper msg

                ApiError err ->
                    Error err

                Reroute route ->
                    NewUrl route
        )
        cmd


notImplementedYet : T -> H.Html Msg
notImplementedYet t =
    H.div
        [ A.id "not-implemented" ]
        [ H.text <| t "main.notImplementedYet" ]


sendError : String -> Cmd Msg
sendError msg =
    Http.post "/api/virhe" (Http.stringBody "text/plain" msg) Json.string
        |> Http.send SendErrorResponse
