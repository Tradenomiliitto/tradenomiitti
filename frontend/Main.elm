port module Main exposing (..)

import Ad
import Common
import CreateAd
import Footer
import Home
import Html as H
import Html.Attributes as A
import Html.Events as E
import Json.Decode as Json
import Link exposing (..)
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
import State.Main exposing (..)
import Static
import User

type alias HtmlId = String
port animation : (HtmlId, Bool) -> Cmd msg -- send True on splash screen, False otherwise
port scrollTop : Bool -> Cmd msg


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

   -- We want to react initially to UrlChange as well
    urlCmd = Navigation.modifyUrl (routeToPath (parseLocation location))
    profileCmd = Cmd.map ProfileMessage Profile.getMe
  in
    model ! [ urlCmd, profileCmd ]


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


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    NewUrl route ->
      { model | scrollTop = True } ! [ Navigation.newUrl (routeToPath route) ]

    UrlChange location ->
      let
        shouldScroll = model.scrollTop
        route = parseLocation location
        modelWithRoute = { model | route = route, scrollTop = False }
        ( newModel, cmd ) =
          case route of
            ShowAd adId ->
              modelWithRoute ! [ Cmd.map AdMessage (Ad.getAd adId) ]

            Profile ->
              modelWithRoute ! [ Cmd.map ProfileMessage Profile.initTasks ]

            ListAds ->
              modelWithRoute ! [ Cmd.map ListAdsMessage ListAds.getAds ]

            Home ->
              modelWithRoute ! [ Cmd.map HomeMessage Home.initTasks
                               , animation ("home-intro-canvas", False)
                               ]

            User userId ->
              if Just userId == Maybe.map .id model.profile.user
              then
                { model | route = Profile } ! [ Navigation.modifyUrl (routeToPath Profile) ]
              else
                (modelWithRoute, Cmd.batch [ User.getUser userId, User.getAds userId ] |> Cmd.map UserMessage)

            ListUsers ->
              modelWithRoute ! [ Cmd.map ListUsersMessage ListUsers.getUsers ]

            LoginNeeded _ ->
              modelWithRoute ! [ animation ("login-needed-canvas", False) ]

            Settings ->
              modelWithRoute ! [ Cmd.map SettingsMessage Settings.initTasks ]

            newRoute ->
              (modelWithRoute, Cmd.none)

        needsLogin =
          case (route, Maybe.isJust model.profile.user, model.initialLoading) of
            (CreateAd, False, False) -> True
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
          model ! [ Navigation.newUrl newRoute ]
        else
          newModel ! [ cmd
                     , scrollTop shouldScroll
                     , doConsentNeededAnimation
                     ]

    UserMessage msg ->
      let
        (userModel, cmd) = User.update msg model.user
      in
        ( { model | user = userModel}, Cmd.map UserMessage cmd )

    AllowProfileCreation ->
      let
        (profileModel, cmd) = Profile.update Profile.AllowProfileCreation model.profile
        newModel = { model | profile = profileModel, needsConsent = False }
      in
        newModel ! [ Cmd.map ProfileMessage cmd ]

    ToggleAcceptTerms ->
      { model | acceptsTerms = not model.acceptsTerms } ! []

    ProfileMessage msg ->
      let
        (profileModel, cmd) = Profile.update msg model.profile
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
        } ! [ Cmd.map ProfileMessage cmd
            , redoNewUrlCmd
            ]

    CreateAdMessage msg ->
      let
        (createAdModel, cmd) = CreateAd.update msg model.createAd
      in
        { model | createAd = createAdModel } ! [ Cmd.map CreateAdMessage cmd]

    ListAdsMessage msg ->
      let
        (listAdsModel, cmd) = ListAds.update msg model.listAds
      in
        { model | listAds = listAdsModel } ! [ Cmd.map ListAdsMessage cmd ]

    ListUsersMessage msg ->
      let
        (listUsersModel, cmd) = ListUsers.update msg model.listUsers
      in
        { model | listUsers = listUsersModel } ! [ Cmd.map ListUsersMessage cmd ]

    AdMessage msg ->
      let
        (adModel, cmd) = Ad.update msg model.ad
      in
        { model | ad = adModel } ! [ Cmd.map AdMessage cmd ]

    HomeMessage msg ->
      let
        (homeModel, cmd) = Home.update msg model.home
      in
        { model | home = homeModel } ! [ Cmd.map HomeMessage cmd ]

    SettingsMessage msg ->
      let
        (settingsModel, cmd) = Settings.update msg model.settings
      in
        { model | settings = settingsModel } ! [ Cmd.map SettingsMessage cmd ]

--SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.map ProfileMessage Profile.subscriptions

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
    action =
      if Maybe.isJust model.profile.user
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

    endpoint = if Maybe.isJust model.profile.user
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
          [ H.text linkText
          , linkGraphic
          ]
      ]


viewPage : Model -> H.Html Msg
viewPage model =
  let
    content =
      case model.route of
        User userId ->
          H.map UserMessage <| User.view model.user
        Profile ->
          H.map (mapAppMessage ProfileMessage) <| Profile.View.view model.profile model
        LoginNeeded route ->
          LoginNeeded.view <| ssoUrl model.rootUrl route
        CreateAd ->
          H.map CreateAdMessage <| CreateAd.view model.createAd
        ListAds ->
          H.map (mapAppMessage ListAdsMessage) <| ListAds.view model.listAds
        ShowAd adId ->
          H.map AdMessage <| Ad.view model.ad adId model.profile.user model.rootUrl
        Home ->
          H.map (mapAppMessage HomeMessage) <| Home.view model.home model.profile.user
        ListUsers ->
          H.map (mapAppMessage ListUsersMessage) <| ListUsers.view model.listUsers
        Terms ->
          PreformattedText.view Static.termsHeading Static.termsTexts
        RegisterDescription ->
          PreformattedText.view Static.registerDescriptionHeading Static.registerDescriptionTexts
        Settings ->
          H.map SettingsMessage <| Settings.view model.settings
        route ->
          notImplementedYet
  in
    H.div
      [ A.class "container-fluid app-content" ]
      [ content ]


mapAppMessage : (msg -> Msg) -> AppMessage msg -> Msg
mapAppMessage func message =
  case message of
    Link route ->
      NewUrl route
    LocalMessage mesg ->
      func mesg

notImplementedYet : H.Html Msg
notImplementedYet =
  H.div
    [ A.id "not-implemented" ]
    [ H.text "Tätä ominaisuutta ei ole vielä toteutettu" ]
