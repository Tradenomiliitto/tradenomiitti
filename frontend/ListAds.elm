module ListAds exposing (..)

import Ad
import Common exposing (Filter(..))
import Html as H
import Html.Attributes as A
import Html.Events as E
import Http
import Json.Decode as Json
import Link
import List.Extra as List
import Models.Ad
import Models.User exposing (User)
import Nav
import QueryString
import QueryString.Extra as QueryString
import Removal
import State.Config as Config
import State.ListAds exposing (..)
import SvgIcons
import Translation exposing (T)
import Util exposing (UpdateMessage(..), ViewMessage(..))


type Msg
    = UpdateAds Int (List Models.Ad.Ad)
    | FooterAppeared
    | ChangeDomainFilter (Maybe String)
    | ChangePositionFilter (Maybe String)
    | ChangeLocationFilter (Maybe String)
    | ChangeSort Sort
    | RemovalMessage Removal.Msg


update : Msg -> Model -> ( Model, Cmd (UpdateMessage Msg) )
update msg model =
    case msg of
        UpdateAds previousCursor ads ->
            { model
                | ads = List.uniqueBy .id <| model.ads ++ ads

                -- always advance by full amount, so we know when to stop asking for more
                , cursor = previousCursor + limit
            }
                ! []

        FooterAppeared ->
            if Common.shouldNotGetMoreOnFooter model.ads model.cursor then
                model ! []
            else
                model ! [ getAds model ]

        ChangeDomainFilter value ->
            reInitItems { model | selectedDomain = value }

        ChangePositionFilter value ->
            reInitItems { model | selectedPosition = value }

        ChangeLocationFilter value ->
            reInitItems { model | selectedLocation = value }

        ChangeSort value ->
            reInitItems { model | sort = value }

        RemovalMessage msg ->
            let
                ( newRemoval, cmd ) =
                    Removal.update msg model.removal
            in
                { model | removal = newRemoval } ! [ Util.localMap RemovalMessage cmd ]


initTasks : Model -> Cmd (UpdateMessage Msg)
initTasks =
    getAds


reInitItems : Model -> ( Model, Cmd (UpdateMessage Msg) )
reInitItems model =
    let
        newModel =
            { model | ads = [], cursor = 0, removal = Removal.init Removal.Ad }
    in
        newModel ! [ getAds newModel ]


getAds : Model -> Cmd (UpdateMessage Msg)
getAds model =
    let
        queryString =
            QueryString.empty
                |> QueryString.add "limit" (toString limit)
                |> QueryString.add "offset" (toString model.cursor)
                |> QueryString.optional "domain" model.selectedDomain
                |> QueryString.optional "position" model.selectedPosition
                |> QueryString.optional "location" model.selectedLocation
                |> QueryString.add "order" (sortToString model.sort)
                |> QueryString.render

        url =
            "/api/ilmoitukset/" ++ queryString

        request =
            Http.get url (Json.list Models.Ad.adDecoder)
    in
        Util.errorHandlingSend (UpdateAds model.cursor) request


view : T -> Maybe User -> Model -> Config.Model -> H.Html (ViewMessage Msg)
view t loggedInUserMaybe model config =
    let
        sorterRow =
            H.map LocalViewMessage <|
                H.div
                    [ A.class "row" ]
                    [ H.div
                        [ A.class "col-xs-12" ]
                        [ H.button
                            [ A.classList
                                [ ( "btn", True )
                                , ( "list-ads__sorter-button", True )
                                , ( "list-ads__sorter-button--active"
                                  , List.member model.sort [ CreatedDesc, CreatedAsc ]
                                  )
                                ]
                            , E.onClick
                                (ChangeSort <|
                                    if model.sort == CreatedDesc then
                                        CreatedAsc
                                    else
                                        CreatedDesc
                                )
                            ]
                            [ H.text <| t "listAds.sort.date"
                            , H.i
                                [ A.classList
                                    [ ( "fa", True )
                                    , ( "fa-chevron-down", model.sort == CreatedDesc )
                                    , ( "fa-chevron-up", model.sort == CreatedAsc )
                                    ]
                                ]
                                []
                            ]
                        , H.button
                            [ A.classList
                                [ ( "btn", True )
                                , ( "list-ads__sorter-button", True )
                                , ( "list-ads__sorter-button--active"
                                  , List.member model.sort [ AnswerCountDesc, AnswerCountAsc ]
                                  )
                                ]
                            , E.onClick
                                (ChangeSort <|
                                    if model.sort == AnswerCountDesc then
                                        AnswerCountAsc
                                    else
                                        AnswerCountDesc
                                )
                            ]
                            [ H.text <| t "listAds.sort.answerCount"
                            , H.i
                                [ A.classList
                                    [ ( "fa", True )
                                    , ( "fa-chevron-down", model.sort == AnswerCountDesc )
                                    , ( "fa-chevron-up", model.sort == AnswerCountAsc )
                                    ]
                                ]
                                []
                            ]
                        , if loggedInUserMaybe /= Nothing then
                            H.button
                                [ A.classList
                                    [ ( "btn", True )
                                    , ( "list-ads__sorter-button", True )
                                    , ( "list-ads__sorter-button--active", model.sort == NewestAnswerDesc )
                                    ]
                                , E.onClick (ChangeSort NewestAnswerDesc)
                                ]
                                [ H.text <| t "listAds.sort.newestAnswer" ]
                          else
                            H.text ""
                        , H.label
                            [ A.class "list-ads__hide-job-ads" ]
                            [ H.input
                                [ A.type_ "checkbox"
                                ]
                                []
                            , H.span
                                []
                                [ H.text (t "listAds.hideJobAds")
                                ]
                            ]
                        ]
                    ]
    in
        H.div []
            [ H.div
                [ A.class "container" ]
                [ H.div
                    [ A.class "row" ]
                    [ H.div
                        [ A.class "col-sm-12" ]
                        [ H.h1
                            [ A.class "list-ads__header" ]
                            [ H.text <| t "listAds.heading" ]
                        ]
                    ]
                , H.div
                    [ A.class "row list-users__filters" ]
                    [ H.div
                        [ A.class "col-xs-12 col-sm-4" ]
                        [ Common.select t "list-users" (LocalViewMessage << ChangeDomainFilter) Domain config.domainOptions model ]
                    , H.div
                        [ A.class "col-xs-12 col-sm-4" ]
                        [ Common.select t "list-users" (LocalViewMessage << ChangePositionFilter) Position config.positionOptions model ]
                    , H.div
                        [ A.class "col-xs-12 col-sm-4" ]
                        [ Common.select t "list-users" (LocalViewMessage << ChangeLocationFilter) Location Config.finnishRegions model ]
                    ]
                ]
            , H.div
                [ A.class "list-ads__list-background" ]
                [ H.div
                    [ A.class "container last-row" ]
                    (sorterRow :: (List.map (Util.localViewMap RemovalMessage) <| viewAds t loggedInUserMaybe model.removal model.ads))
                ]
            ]


sortToString : Sort -> String
sortToString sort =
    case sort of
        CreatedDesc ->
            "created_at_desc"

        CreatedAsc ->
            "created_at_asc"

        AnswerCountDesc ->
            "answers_desc"

        AnswerCountAsc ->
            "answers_asc"

        NewestAnswerDesc ->
            "newest_answer_desc"


viewAds : T -> Maybe User -> Removal.Model -> List Models.Ad.Ad -> List (H.Html (ViewMessage Removal.Msg))
viewAds t loggedInUserMaybe removal ads =
    let
        adsHtml =
            List.indexedMap (adListView t loggedInUserMaybe removal) ads

        rows =
            Common.chunk2 adsHtml

        rowsHtml =
            List.map row rows
    in
        rowsHtml


row : List (H.Html msg) -> H.Html msg
row ads =
    H.div
        [ A.class "row list-ads__row" ]
        ads


adListView : T -> Maybe User -> Removal.Model -> Int -> Models.Ad.Ad -> H.Html (ViewMessage Removal.Msg)
adListView t loggedInUserMaybe removal index ad =
    H.div
        [ A.class "col-xs-12 col-sm-6 list-ads__item-container"
        ]
        [ H.div
            [ A.class "list-ads__ad-preview list-ads__item" ]
          <|
            [ H.a
                [ A.href (Nav.routeToPath (Nav.ShowAd ad.id))
                , Link.action (Nav.ShowAd ad.id)
                , A.class "card-link list-ads__item-expanding-part"
                ]
                [ Ad.viewDate t ad.createdAt
                , H.h3
                    [ A.class "list-ads__ad-preview-heading" ]
                    [ H.text ad.heading ]
                , H.p [ A.class "list-ads__ad-preview-content" ] [ H.text (Util.truncateContent ad.content 200) ]
                ]
            , H.hr [ A.class "list-ads__item-ruler" ] []
            , H.div
                []
                [ H.a
                    [ A.class "list-ads__ad-preview-answer-count card-link"
                    , A.href (Nav.routeToPath (Nav.ShowAd ad.id))
                    , Link.action (Nav.ShowAd ad.id)
                    ]
                    [ H.span
                        [ A.class "list-ads__ad-preview-answer-count-number" ]
                        [ H.text << toString <| Models.Ad.adCount ad.answers ]
                    , SvgIcons.answers
                    ]
                , H.div [ A.class "list-ads__ad-preview-author-info" ] [ Common.authorInfo ad.createdBy ]
                ]
            ]
                ++ Removal.view t loggedInUserMaybe index ad removal
        ]
