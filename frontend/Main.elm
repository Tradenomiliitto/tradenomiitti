import Ad
import CreateAd
import Html as H
import Html.Attributes as A
import Html.Events as E
import Json.Decode as Json
import ListAds
import LoginNeeded
import Maybe.Extra as Maybe
import Nav exposing (..)
import Navigation
import Profile.Main as Profile
import Profile.View
import State.Main exposing (..)
import User

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
  | UserMessage User.Msg
  | ProfileMessage Profile.Msg
  | CreateAdMessage CreateAd.Msg
  | ListAdsMessage ListAds.Msg
  | AdMessage Ad.Msg

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    NewUrl route ->
      model ! [ Navigation.newUrl (routeToPath Profile) ]

    UrlChange location ->
      let
        newRoute = parseLocation location
        modelWithRoute = { model | route = newRoute }
        ( newModel, cmd ) =
          case newRoute of
            ShowAd adId ->
              modelWithRoute ! [ Cmd.map AdMessage (Ad.getAd adId) ]

            Profile ->
              modelWithRoute ! [ Cmd.map ProfileMessage Profile.initTasks ]

            ListAds ->
              modelWithRoute ! [ Cmd.map ListAdsMessage ListAds.getAds ]

            User userId ->
              if Just userId == Maybe.map .id model.profile.user
              then
                { model | route = Profile } ! [ Navigation.newUrl (routeToPath Profile) ]
              else
                (modelWithRoute, Cmd.batch [ User.getUser userId, User.getAds userId ] |> Cmd.map UserMessage)

            newRoute ->
              (modelWithRoute, Cmd.none)
      in
        newModel ! [ cmd ]

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
            Navigation.newUrl (routeToPath model.route)
          else
            Cmd.none

      in
        { model
          | profile = profileModel
          , initialLoading = initialLoading
          , needsConsent = needsConsent
        } ! [ Cmd.map ProfileMessage cmd, redoNewUrlCmd ]

    CreateAdMessage msg ->
      let
        (createAdModel, cmd) = CreateAd.update msg model.createAd
      in
        { model | createAd = createAdModel } ! [ Cmd.map CreateAdMessage cmd]

    ListAdsMessage msg ->
      let
        (listAdsModel, cmd) = ListAds.update msg model.listAds
      in
        { model | listAds = listAdsModel } ! [ Cmd.map
        ListAdsMessage cmd ]

    AdMessage msg ->
      let
        (adModel, cmd) = Ad.update msg model.ad
      in
        { model | ad = adModel } ! [ Cmd.map AdMessage cmd ]

--SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none

-- VIEW

view : Model -> H.Html Msg
view model =
  if model.initialLoading
  then
    H.div
      [ A.class "splash-screen" ]
      [ logoImage 400 ]
  else
    if model.needsConsent
    then
      H.div
        [ A.class "splash-screen" ]
          [ H.div
            [ A.class "profile__consent-needed col-xs-12 col-md-5" ]
            [ H.h1 [] [ H.text "Tervetuloa Tradenomiittiin!" ]
            , H.p [] [ H.text "Tehdäksemme palvelun käytöstä mahdollisimman vaivatonta hyödynnämme Tradenomiliiton olemassa olevia jäsentietoja (nimesi, työhistoriasi). Luomalla profiilin hyväksyt tietojesi käytön Tradenomiitti-palvelussa. Voit muokata tietojasi myöhemmin." ]
            , H.button
              [ A.class "btn btn-lg profile__consent-btn-inverse"
              , E.onClick (AllowProfileCreation)
              ]
              [ H.text "Luo profiili" ]
            ]
          ]
    else
      H.div []
        [ navigation model
        , viewPage model
        ]

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
    [ link route ]

viewLink : Route -> H.Html Msg
viewLink route =
  H.li
    []
    [ link route ]

viewProfileLink : Model -> H.Html Msg
viewProfileLink model =
  let
    route = Profile
    action =
      if Maybe.isJust model.profile.user
      then
        [ E.onWithOptions
            "click"
            { stopPropagation = False
            , preventDefault = True
            }
            (Json.succeed <| NewUrl route)
        ]
      else
        []

    endpoint = if Maybe.isJust model.profile.user
               then routeToPath route
               else ssoUrl model.rootUrl route
    linkText =
      model.profile.user
        |> Maybe.map .name
        |> Maybe.withDefault "Kirjaudu"

    linkGraphic =
      model.profile.user
        |> Maybe.map
          (\u ->
             H.span
             [ A.class "navbar__profile-pic" ]
             [ {- here an img tag? -}]
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


link : Route -> H.Html Msg
link route =
  let
    action =
      E.onWithOptions
        "click"
        { stopPropagation = False
        , preventDefault = True
        }
        (Json.succeed <| NewUrl route)
  in
    H.a
      [ action
      , A.href (routeToPath route)
      ]
      [ H.text (routeToString route) ]

viewPage : Model -> H.Html Msg
viewPage model =
  let
    content =
      case model.route of
        User userId ->
          H.map UserMessage <| User.view model.user
        Profile ->
          H.map ProfileMessage <| Profile.View.view model.profile model
        CreateAd ->
          if Maybe.isJust model.profile.user
          then
            H.map CreateAdMessage <| CreateAd.view model.createAd
          else
            LoginNeeded.view <| ssoUrl model.rootUrl model.route
        ListAds ->
          H.map ListAdsMessage <| ListAds.view model.listAds
        ShowAd adId ->
          H.map AdMessage <| Ad.view model.ad adId model.profile.user model.rootUrl
        route ->
          notImplementedYet
  in
    H.div
      [ A.class "container-fluid app-content" ]
      [ content ]


notImplementedYet : H.Html Msg
notImplementedYet =
  H.div
    [ A.id "not-implemented" ]
    [ H.text "Tätä ominaisuutta ei ole vielä toteutettu" ]


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
