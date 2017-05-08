port module Main exposing (..)

import Ad
import Contacts
import Common
import Config
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
import Navigation
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
import Static
import User
import Util exposing (ViewMessage(..), UpdateMessage(..))

type alias HtmlId = String
port animation : (HtmlId, Bool) -> Cmd msg -- send True on splash screen, False otherwise
port scrollTop : Bool -> Cmd msg -- parameter tells whether to scroll
port sendGaPageView : String -> Cmd msg -- parameter is path
port footerAppeared : (Bool -> msg) -> Sub msg
port closeMenu : Bool -> Cmd msg -- parameter is ignored
port showAlert : String -> Cmd msg

main : Program Never Model Msg
main =
  Navigation.program UrlChange
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }

init : Navigation.Location -> ( Model, Cmd Msg )
init location =
  let
    model = initState location

    -- after the profile is loaded, an urlchange event is triggered
    profileCmd = unpackUpdateMessage ProfileMessage Profile.getMe
    configCmd = unpackUpdateMessage ConfigMessage Config.initTasks
  in
    model ! [ profileCmd, configCmd ]


-- UPDATE

type Msg
  = NewUrl Route
  | UrlChange Navigation.Location
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
  | Error Http.Error
  | SendErrorResponse (Result Http.Error String)
  | NoOp


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    NewUrl route ->
      { model | scrollTop = True } !
        [ Navigation.newUrl (routeToPath route)
        , sendGaPageView (routeToPath route)
        , closeMenu True
        ]

    UrlChange location ->
      let
        shouldScroll = model.scrollTop

        route = parseLocation location
        modelWithRoute = { model | route = route, scrollTop = False }

        initWithUpdateMessage initModel mapper cmd =
          if shouldScroll then
            initModel ! [ unpackUpdateMessage mapper cmd ]
          else
            modelWithRoute ! []

        ( newModel, cmd ) =
          case route of
            ShowAd adId ->
              initWithUpdateMessage { modelWithRoute | ad = State.Ad.init }
                AdMessage (Ad.getAd adId)

            Profile ->
              let
                cleanProfile = State.Profile.init
                initializedWithOldUser = { cleanProfile | user = modelWithRoute.profile.user }
                initialModel = { modelWithRoute | profile = initializedWithOldUser }
              in
                initWithUpdateMessage initialModel
                  ProfileMessage Profile.initTasks

            ListAds ->
              let newListAds = State.ListAds.init
              in
                initWithUpdateMessage { modelWithRoute | listAds = newListAds }
                ListAdsMessage (ListAds.initTasks newListAds)

            Home ->
              let
                newHome = State.Home.init
                (newModel, cmd) =
                  initWithUpdateMessage { modelWithRoute | home = newHome }
                    HomeMessage (Home.initTasks newHome)
              in
                newModel ! [ cmd, animation ("home-intro-canvas", False) ]

            User userId ->
              if Just userId == Maybe.map .id model.profile.user
              then
                { model | route = Profile } ! [ Navigation.modifyUrl (routeToPath Profile) ]
              else
                initWithUpdateMessage { modelWithRoute | user = State.User.init }
                  UserMessage (User.initTasks userId)

            ListUsers ->
              let newListUsers = State.ListUsers.init
              in
                initWithUpdateMessage { modelWithRoute | listUsers = newListUsers }
                  ListUsersMessage (ListUsers.initTasks newListUsers)

            LoginNeeded _ ->
              modelWithRoute ! [ animation ("login-needed-canvas", False) ]

            Settings ->
              initWithUpdateMessage { modelWithRoute | settings = State.Settings.init } SettingsMessage Settings.initTasks

            Contacts ->
              initWithUpdateMessage { modelWithRoute | contacts = State.Contacts.init } ContactsMessage Contacts.initTasks

            newRoute ->
              (modelWithRoute, Cmd.none)

        needsLogin =
          case (route, Maybe.isJust model.profile.user, model.initialLoading) of
            (CreateAd, False, False) -> True
            (Profile, False, False) -> True
            (Settings, False, False) -> True
            _ -> False

        newRoute =
          if needsLogin
          then
            routeToPath <| LoginNeeded (routeToPath route |> Just)
          else
            routeToPath route

        doConsentNeededAnimation =
          if (not model.initialLoading) && model.needsConsent then
            animation ("consent-needed-canvas", True)
          else
            Cmd.none

      in
        if needsLogin
        then
          model ! [ Navigation.modifyUrl newRoute ]
        else
          newModel ! [ cmd
                     , scrollTop shouldScroll
                     , doConsentNeededAnimation
                     ]

    UserMessage msg ->
      let
        (userModel, cmd) = User.update msg model.user
      in
        ( { model | user = userModel}, unpackUpdateMessage UserMessage cmd )

    AllowProfileCreation ->
      let
        (profileModel, cmd) = Profile.update Profile.AllowProfileCreation model.profile model.config
        newModel = { model | profile = profileModel }
      in
        newModel ! [ unpackUpdateMessage ProfileMessage cmd ]

    ToggleAcceptTerms ->
      { model | acceptsTerms = not model.acceptsTerms } ! []

    ProfileMessage msg ->
      let
        (profileModel, cmd) = Profile.update msg model.profile model.config
        (initialLoading, needsConsent) =
          case msg of
            Profile.GetMe (Ok user) ->
              (False, not user.profileCreated)
            Profile.GetMe (Err _) ->
              (False, False)
            _ ->
              (model.initialLoading, model.needsConsent)

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
        } ! [ unpackUpdateMessage ProfileMessage cmd
            , redoNewUrlCmd
            ]

    CreateAdMessage msg ->
      let
        (createAdModel, cmd) = CreateAd.update msg model.createAd
      in
        { model | createAd = createAdModel } !
          [ unpackUpdateMessage CreateAdMessage cmd]

    ListAdsMessage msg ->
      let
        (listAdsModel, cmd) = ListAds.update msg model.listAds
      in
        { model | listAds = listAdsModel } ! [ unpackUpdateMessage ListAdsMessage cmd ]

    ListUsersMessage msg ->
      let
        (listUsersModel, cmd) = ListUsers.update msg model.listUsers
      in
        { model | listUsers = listUsersModel } ! [ unpackUpdateMessage ListUsersMessage cmd ]

    AdMessage msg ->
      let
        (adModel, cmd) = Ad.update msg model.ad
      in
        { model | ad = adModel } ! [ unpackUpdateMessage AdMessage cmd ]

    HomeMessage msg ->
      let
        (homeModel, cmd) = Home.update msg model.home
      in
        { model | home = homeModel } ! [ unpackUpdateMessage HomeMessage cmd ]

    SettingsMessage msg ->
      let
        (settingsModel, cmd) = Settings.update msg model.settings
      in
        { model | settings = settingsModel } ! [ unpackUpdateMessage SettingsMessage cmd ]

    ConfigMessage msg ->
      let
        (configModel, cmd) = Config.update msg model.config
      in
        { model | config = configModel } ! [ cmd ]

    ContactsMessage msg ->
      let
        (contactsModel, cmd) = Contacts.update msg model.contacts
      in
        { model | contacts = contactsModel } ! [ cmd ]

    Error err ->
      let
        cmd =
          case err of
            Http.BadUrl str -> sendError <| "BadUrl " ++ str
            Http.Timeout -> showAlert "Vastauksen saaminen kesti liian kauan, yritä myöhemmin uudelleen"
            Http.NetworkError -> showAlert "Yhteydessä on ongelma, yritä myöhemmin uudelleen"
            Http.BadPayload error { body } -> sendError <| "Jotain meni pieleen. Verkosta tuli\n\n"
                                             ++ body
                                             ++ "\n\nja virhe oli\n\n"
                                             ++ error
            Http.BadStatus { status, body } ->
              case status.code of
                404 ->
                  showAlert <| "Haettua sisältöä ei löytynyt. Se on voitu poistaa tai osoitteessa voi olla virhe. Voit ottaa yhteyttä osoitteeseen " ++ supportEmail ++ " halutessasi. Ota silloin kuvakaappaus sivusta ja lähetä se viestin liitteenä. " ++ body
                _ ->
                  showAlert <| errorCodeToUserVisibleErrorMessage body
      in
        model ! [ cmd ]

    SendErrorResponse (Ok str) ->
      model ! [ showAlert <| errorCodeToUserVisibleErrorMessage str ]

    SendErrorResponse (Err err) ->
      model ! [ showAlert <| toString err ++ "Järjestelmässä on jotain pahasti pielessä, tutkimme asiaa" ]

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
  in
    Sub.batch
      [ Sub.map ProfileMessage (Profile.subscriptions model.profile)
      , footerListener
      ]

-- VIEW

view : Model -> H.Html Msg
view model =
  let
    splashScreen =
      H.div
        [ A.class "splash-screen" ]
        [ logoImage 400 ]

    askConsent =
      H.div
        [ A.class "splash-screen" ]
          [ H.canvas [ A.id "consent-needed-canvas", A.class "consent-needed__animation" ] []
          , H.div
            [ A.class "consent-needed col-xs-12 col-md-5" ]
            [ H.h1 [] [ H.text "Tervetuloa Tradenomiittiin!" ]
            , H.p [] [ H.text "Tehdäksemme palvelun käytöstä mahdollisimman vaivatonta hyödynnämme Tradenomiliiton olemassa olevia jäsentietoja (nimesi, työhistoriasi). Luomalla profiilin hyväksyt tietojesi käytön Tradenomiitti-palvelussa. Voit muokata tietojasi myöhemmin." ]
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
                    [ A.class "consent-needed__read-terms"]
                    [ H.text "Hyväksyn palvelun "
                    , H.a
                      [ A.href "/kayttoehdot"
                      , A.target "_blank"
                      , A.class "consent-needed__read-terms-link"
                      ]
                      [ H.text "käyttöehdot" ]
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
                  [ H.text "Luo profiili" ]
                ]
              ]
            ]
          ]

    mainUi =
      H.div [ A.class "page-layout" ]
        [ navigation model
        , viewPage model
        , Footer.view NewUrl
        ]
  in
    if model.initialLoading
    then
      splashScreen
    else
      case (model.needsConsent, model.route) of
        (True, Terms) -> mainUi
        (True, RegisterDescription) -> mainUi
        (True, _) -> askConsent
        _ -> mainUi

--TODO move navbar code to Nav.elm

navigation : Model -> H.Html Msg
navigation model =
  H.nav
    [ A.class "navbar navbar-default navbar-fixed-top" ]
    [ H.div
        [ A.class "navbar-header" ]
        [ H.button
          [ A.class "navbar-toggle collapsed"
          , A.attribute "data-toggle" "collapse"
          , A.attribute "data-target" "#navigation"
          ]
          [ H.span [ A.class "sr-only" ] [ H.text "Navigaation avaus" ]
          , H.span [ A.class "icon-bar" ] []
          , H.span [ A.class "icon-bar" ] []
          , H.span [ A.class "icon-bar" ] []
          ]
        , logo
        ]
    , H.div
        [ A.class "collapse navbar-collapse"
        , A.id "navigation"
        ]
        (navigationList model)
    ]

logo : H.Html Msg
logo =
  H.div
    [ A.class "navbar-brand" ]
    [ H.a
      [ A.id "logo"
      , A.href "/"
      , Common.linkAction Home NewUrl
      ]
      [ logoImage 163
      ]
    ]


logoImage : Int -> H.Html msg
logoImage width =
  H.img
    [ A.alt "Tradenomiitti"
    , A.src "/static/tradenomiitti_logo.svg"
    , A.class "logo-image"
    , A.width width
    ]
    []


navigationList : Model -> List (H.Html Msg)
navigationList model =
  [ H.ul
    [ A.class "nav navbar-nav nav-center" ]
    [ viewLink ListUsers
    , verticalBar
    , viewLink ListAds
    , viewLinkInverse CreateAd
    ]
  , H.ul
    [ A.class "nav navbar-nav navbar-right" ]
    [ viewLink Info
    , verticalBar
    , viewProfileLink model
    ]
  ]

verticalBar : H.Html msg
verticalBar =
  H.li
    [ A.class <| "navbar__vertical-bar" ]
    [ H.div [] []]


viewLinkInverse : Route -> H.Html Msg
viewLinkInverse route =
  H.li
    [ A.class "navbar__inverse-button" ]
    [ Common.link route NewUrl ]

viewLink : Route -> H.Html Msg
viewLink route =
  H.li
    []
    [ Common.link route NewUrl ]

viewProfileLink : Model -> H.Html Msg
viewProfileLink model =
  let
    loggedIn = Maybe.isJust model.profile.user
    action =
      if loggedIn
      then
        [ E.onWithOptions
            "click"
            { stopPropagation = False
            , preventDefault = True
            }
            (Json.succeed <| NewUrl Profile)
        ]
      else
        []

    endpoint = if loggedIn
               then routeToPath Profile
               else ssoUrl model.rootUrl (routeToPath Profile |> Just)
    linkText =
      model.profile.user
        |> Maybe.map (\u -> if u.profileCreated then u.name else "Profiili")
        |> Maybe.withDefault "Kirjaudu"

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
            [])

  in
    H.li
      []
      [ H.a
          ( action ++
          [ A.href endpoint
          ])
          [ H.span
            [ A.classList [ ("navbar__login-link", not loggedIn) ]]
            [ H.text linkText
            ]
          , linkGraphic
          ]
      ]


viewPage : Model -> H.Html Msg
viewPage model =
  let
    content =
      case model.route of
        User userId ->
          unpackViewMessage UserMessage <| User.view model.user model.profile.user model.config
        Profile ->
          unpackViewMessage ProfileMessage <| Profile.View.view model.profile model
        LoginNeeded route ->
          LoginNeeded.view <| ssoUrl model.rootUrl route
        CreateAd ->
          H.map CreateAdMessage <| CreateAd.view model.config model.createAd
        ListAds ->
          unpackViewMessage ListAdsMessage <| ListAds.view model.listAds model.config
        ShowAd adId ->
          unpackViewMessage AdMessage <| Ad.view model.ad adId model.profile.user model.rootUrl
        Home ->
          unpackViewMessage HomeMessage <| Home.view model.home model.profile.user
        ListUsers ->
          unpackViewMessage ListUsersMessage <| ListUsers.view model.listUsers model.config (Maybe.isJust model.profile.user)
        Terms ->
          PreformattedText.view Static.termsHeading Static.termsTexts
        RegisterDescription ->
          PreformattedText.view Static.registerDescriptionHeading Static.registerDescriptionTexts
        Settings ->
          unpackViewMessage SettingsMessage <| Settings.view model.settings model.profile.user
        Info ->
          Info.view
        Contacts ->
          unpackViewMessage identity <| Contacts.view model.contacts model.profile.user
        NotFound ->
          notImplementedYet
  in
    H.div
      [ A.class "app-content" ]
      [ content ]


unpackViewMessage : (msg -> Msg) -> H.Html (ViewMessage msg) -> H.Html Msg
unpackViewMessage func html =
  H.map (\message ->
           case message of
             Link route -> NewUrl route
             LocalViewMessage mesg -> func mesg
        ) html

unpackUpdateMessage : (msg -> Msg) -> Cmd (UpdateMessage msg) -> Cmd Msg
unpackUpdateMessage mapper cmd =
  Cmd.map (\appMsg ->
             case appMsg of
               LocalUpdateMessage msg -> mapper msg
               ApiError err -> Error err
               Reroute route -> NewUrl route
          ) cmd

notImplementedYet : H.Html Msg
notImplementedYet =
  H.div
    [ A.id "not-implemented" ]
    [ H.text "Tätä ominaisuutta ei ole vielä toteutettu" ]


sendError : String -> Cmd Msg
sendError msg =
  Http.post "/api/virhe" (Http.stringBody "text/plain" msg) Json.string
    |> Http.send SendErrorResponse

supportEmail : String
supportEmail = "tradenomiitti@tral.fi"

errorCodeToUserVisibleErrorMessage : String -> String
errorCodeToUserVisibleErrorMessage body =
  "Jotain meni pieleen. Virheen tunnus on " ++ body ++ ". Meille olisi suuri apu, jos otat kuvakaappauksen koko sivusta ja lähetät sen osoitteeseen " ++ supportEmail ++ "."
