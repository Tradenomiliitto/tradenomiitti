port module Home exposing (Msg(..), initTasks, introAnimation, introBoxes, introScreen, listAdsButtons, listAdsHeading, listFourAds, listLatestAds, listThreeUsers, listUsers, listUsersButtons, listUsersHeading, readMoreButton, scrollHomeBelowFold, sectionHeader, tradenomiImage, tradenomiittiHeader, tradenomiittiInfo, tradenomiittiInfoText, tradenomiittiRow, tradenomiittiSection, update, view)

import Html as H
import Html.Attributes as A
import Html.Events as E
import Link
import ListAds
import ListUsers
import Maybe.Extra as Maybe
import Models.User exposing (User)
import Nav
import Removal
import State.Home exposing (..)
import Translation exposing (T)
import Util exposing (UpdateMessage(..), ViewMessage(..))


type Msg
    = ListAdsMessage ListAds.Msg
    | ListUsersMessage ListUsers.Msg
    | ClickCreateProfile
    | ScrollBelowFold
    | RemovalMessage Removal.Msg


{-| param is ignored
-}
port scrollHomeBelowFold : Bool -> Cmd msg


update : Msg -> Model -> ( Model, Cmd (UpdateMessage Msg) )
update outerMsg model =
    case outerMsg of
        ListAdsMessage msg ->
            let
                ( listAdsModel, cmd ) =
                    ListAds.update msg model.listAds
            in
            ( { model | listAds = listAdsModel }
            , Util.localMap ListAdsMessage cmd
            )

        ListUsersMessage msg ->
            let
                ( listUsersModel, cmd ) =
                    ListUsers.update msg model.listUsers
            in
            ( { model | listUsers = listUsersModel }
            , Util.localMap ListUsersMessage cmd
            )

        ClickCreateProfile ->
            ( { model | createProfileClicked = True }
            , Cmd.none
            )

        ScrollBelowFold ->
            ( model
            , scrollHomeBelowFold True
            )

        RemovalMessage msg ->
            let
                ( newRemoval, cmd ) =
                    Removal.update msg model.removal
            in
            ( { model | removal = newRemoval }
            , Util.localMap RemovalMessage cmd
            )


initTasks : Model -> Cmd (UpdateMessage Msg)
initTasks model =
    Cmd.batch
        [ Util.localMap ListAdsMessage (ListAds.initTasks model.listAds)
        , Util.localMap ListUsersMessage (ListUsers.initTasks model.listUsers)
        ]


view : T -> Model -> Maybe User -> H.Html (ViewMessage Msg)
view t model loggedInUserMaybe =
    H.div
        []
        [ introScreen t loggedInUserMaybe
        , listLatestAds t loggedInUserMaybe model
        , listUsers t model loggedInUserMaybe
        , tradenomiittiSection t
        ]



-- FIRST INFO SCREEN --


introScreen : T -> Maybe User -> H.Html (ViewMessage Msg)
introScreen t loggedInUserMaybe =
    H.div
        [ A.class "home__intro-screen" ]
        (introAnimation :: introBoxes t loggedInUserMaybe)


introAnimation : H.Html msg
introAnimation =
    H.canvas
        [ A.id "home-intro-canvas"
        , A.class "home__intro-canvas"
        ]
        []


introBoxes : T -> Maybe User -> List (H.Html (ViewMessage Msg))
introBoxes t loggedInUserMaybe =
    let
        createProfile =
            case loggedInUserMaybe of
                Just _ ->
                    []

                Nothing ->
                    [ H.div
                        [ A.class "home__introbox home__introbox--button-container col-xs-11 col-sm-4 col-sm-offset-4" ]
                        [ Link.button (t "home.introbox.createProfile")
                            "home__introbox--button btn btn-primary"
                            (Nav.LoginNeeded (Nav.ToProfile |> Nav.routeToPath |> Just))
                        ]
                    ]
    in
    [ H.div
        [ A.class "home__introbox col-xs-11 col-sm-6 col-sm-offset-3" ]
        [ H.h2
            [ A.class "home__introbox--heading" ]
            [ H.text (t "home.introbox.heading") ]
        ]
    , H.div
        [ A.class "home__introbox col-xs-11 col-sm-6 col-sm-offset-3" ]
        [ H.div
            [ A.class "home__introbox--content" ]
            [ H.text (t "home.introbox.content") ]
        ]
    ]
        ++ createProfile
        ++ [ H.i
                [ A.class "fa fa-angle-double-down fa-3x home__introbox-check-more"
                , E.onClick (LocalViewMessage ScrollBelowFold)
                ]
                []
           ]



-- LIST LATEST ADS --


listLatestAds : T -> Maybe User -> Model -> H.Html (ViewMessage Msg)
listLatestAds t loggedInUserMaybe model =
    H.div
        [ A.class "home__latest-ads" ]
        [ H.div
            [ A.class "home__section--container" ]
            [ listAdsHeading t
            , listFourAds t loggedInUserMaybe model
            ]
        ]


listAdsHeading : T -> H.Html (ViewMessage Msg)
listAdsHeading t =
    H.div
        [ A.class "home__section--heading row" ]
        [ sectionHeader (t "home.listAds.heading")
        , listAdsButtons t
        ]


listAdsButtons : T -> H.Html (ViewMessage Msg)
listAdsButtons t =
    H.div
        [ A.class "home__section--heading--buttons col-sm-7" ]
        [ Link.button
            (t "home.listAds.buttonListAds")
            "home__section--heading--buttons--inverse btn btn-primary"
            Nav.ListAds
        , Link.button
            (t "home.listAds.buttonCreateAd")
            "home__section--heading--buttons--normal btn btn-primary"
            Nav.CreateAd
        ]


sectionHeader : String -> H.Html msg
sectionHeader title =
    H.div
        [ A.class "home__section--heading--text col-sm-5" ]
        [ H.text title ]


listFourAds : T -> Maybe User -> Model -> H.Html (ViewMessage Msg)
listFourAds t loggedInUserMaybe model =
    Util.localViewMap RemovalMessage <|
        H.div
            []
            (ListAds.viewAds t loggedInUserMaybe model.removal (List.take 4 model.listAds.ads))



-- LIST USERS --


listUsers : T -> Model -> Maybe User -> H.Html (ViewMessage msg)
listUsers t model loggedInUserMaybe =
    H.div
        [ A.class "home__list-users" ]
        [ H.div
            [ A.class "home__section--container" ]
            [ listUsersHeading t loggedInUserMaybe
            , listThreeUsers model
            ]
        ]


listUsersHeading : T -> Maybe User -> H.Html (ViewMessage msg)
listUsersHeading t loggedInUserMaybe =
    H.div
        [ A.class "home__section--heading row" ]
        [ sectionHeader <| t "home.listUsers.heading"
        , listUsersButtons t loggedInUserMaybe
        ]


listUsersButtons : T -> Maybe User -> H.Html (ViewMessage msg)
listUsersButtons t loggedInUserMaybe =
    H.div
        [ A.class "home__section--heading--buttons col-sm-7" ]
        [ Link.button
            (t "home.listUsers.buttonListUsers")
            "home__section--heading--buttons--inverse btn btn-primary"
            Nav.ListUsers
        , Link.button
            (if Maybe.isJust loggedInUserMaybe then
                t "home.listUsers.buttonEditProfile"

             else
                t "home.listUsers.buttonCreateProfile"
            )
            "home__section--heading--buttons--normal btn btn-primary"
            (case loggedInUserMaybe of
                Just user ->
                    Nav.Profile user.id

                Nothing ->
                    Nav.LoginNeeded << Just << Nav.routeToPath <| Nav.ToProfile
            )
        ]


listThreeUsers : Model -> H.Html (ViewMessage msg)
listThreeUsers model =
    ListUsers.row
        (List.map ListUsers.viewUser (List.take 3 model.listUsers.users))



-- TRADENOMIITTI AD --


tradenomiittiSection : T -> H.Html (ViewMessage msg)
tradenomiittiSection t =
    H.div
        [ A.class "home__tradenomiitti--background" ]
        [ H.div
            [ A.class "home__tradenomiitti--container" ]
            [ tradenomiittiRow t ]
        ]


tradenomiittiRow : T -> H.Html (ViewMessage msg)
tradenomiittiRow t =
    H.div
        [ A.class "row home__tradenomiitti-info-row" ]
        [ H.div [ A.class "home__tradenomiitti-info-container  col-md-6" ] [ tradenomiittiInfo t ]
        , tradenomiImage
        ]


tradenomiittiInfo : T -> H.Html (ViewMessage msg)
tradenomiittiInfo t =
    H.div
        [ A.class "home__tradenomiitti-info" ]
        [ tradenomiittiHeader t
        , tradenomiittiInfoText t
        , readMoreButton t
        ]


tradenomiittiHeader : T -> H.Html msg
tradenomiittiHeader t =
    H.h2
        [ A.class "home__tradenomiitti-info--header" ]
        [ H.text <| t "home.tradenomiittiInfo.heading" ]


tradenomiittiInfoText : T -> H.Html msg
tradenomiittiInfoText t =
    H.div
        [ A.class "home__tradenomiitti-info-content" ]
        [ H.p
            [ A.class "home__tradenomiitti-info-text" ]
            [ H.text <| t "home.tradenomiittiInfo.paragraph1" ]
        , H.p
            [ A.class "home__tradenomiitti-info-text" ]
            [ H.text <| t "home.tradenomiittiInfo.paragraph2" ]
        ]


readMoreButton : T -> H.Html (ViewMessage msg)
readMoreButton t =
    Link.link
        (t "common.readMore")
        "home__tradenomiitti-info--read-more-button btn btn-primary"
        Nav.Info


tradenomiImage : H.Html msg
tradenomiImage =
    H.div
        [ A.class "col-md-6" ]
        [ H.img
            [ A.class "home__tradenomiitti--image"
            , A.src "/static/home_image.jpg"
            ]
            []
        ]
