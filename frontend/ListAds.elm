module ListAds exposing (..)

import Ad
import Common exposing (Filter(..))
import Html as H
import Html.Attributes as A
import Http
import Json.Decode as Json
import Link
import List.Extra as List
import Models.Ad
import Models.User exposing (User)
import Nav
import QueryString
import QueryString.Extra as QueryString
import State.Config as Config
import State.ListAds exposing (..)
import SvgIcons
import Util exposing (ViewMessage(..), UpdateMessage(..))

type Msg
  = UpdateAds Int (List Models.Ad.Ad)
  | FooterAppeared
  | ChangeDomainFilter (Maybe String)
  | ChangePositionFilter (Maybe String)
  | ChangeLocationFilter (Maybe String)


update : Msg -> Model -> (Model, Cmd (UpdateMessage Msg))
update msg model =
  case msg of
    UpdateAds previousCursor ads ->
      { model
        | ads = List.uniqueBy .id <| model.ads ++ ads
        -- always advance by full amount, so we know when to stop asking for more
        , cursor = previousCursor + limit
      } ! []

    FooterAppeared ->
      if Common.shouldNotGetMoreOnFooter model.ads model.cursor
      then
        model ! []
      else
        model ! [ getAds model ]

    ChangeDomainFilter value ->
      reInitItems { model | selectedDomain = value }

    ChangePositionFilter value ->
      reInitItems { model | selectedPosition = value }

    ChangeLocationFilter value ->
      reInitItems { model | selectedLocation = value }

initTasks : Model -> Cmd (UpdateMessage Msg)
initTasks = getAds

reInitItems : Model -> (Model, Cmd (UpdateMessage Msg))
reInitItems model =
  let
    newModel = { model | ads = [], cursor = 0 }
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
        |> QueryString.render

    url = "/api/ilmoitukset/" ++ queryString
    request = Http.get url (Json.list Models.Ad.adDecoder)
  in
    Util.errorHandlingSend (UpdateAds model.cursor) request


view : Maybe User -> Model -> Config.Model -> H.Html (ViewMessage Msg)
view userMaybe model config =
  userMaybe
    |> Maybe.map (\user ->
      H.div []
        [ H.div
          [ A.class "container" ]
          [ H.div
            [ A.class "row" ]
            [ H.div
              [ A.class "col-sm-12" ]
              [ H.h1
                [ A.class "list-ads__header" ]
                [ H.text "Selaa ilmoituksia" ]
              ]
            ]
          , H.div
            [ A.class "row list-users__filters" ]
            [ H.div
              [ A.class "col-xs-12 col-sm-4" ]
              [ Common.select "list-users" (LocalViewMessage << ChangeDomainFilter) Domain config.domainOptions model ]
            , H.div
              [ A.class "col-xs-12 col-sm-4" ]
              [ Common.select "list-users" (LocalViewMessage << ChangePositionFilter) Position config.positionOptions model ]
            , H.div
              [ A.class "col-xs-12 col-sm-4" ]
              [ Common.select "list-users" (LocalViewMessage << ChangeLocationFilter) Location Config.finnishRegions model ]
            ]
          ]
        , H.div
          [ A.class "list-ads__list-background"]
          [ H.div
            [ A.class "container last-row" ]
            (viewAds user model.ads)
          ]
        ])
    |> Maybe.withDefault (H.div [] [])

viewAds : User -> List Models.Ad.Ad -> List (H.Html (ViewMessage msg))
viewAds user ads =
  let
    adsHtml = List.map (adListView user) ads
    rows = Common.chunk2 adsHtml
    rowsHtml = List.map row rows
  in
    rowsHtml

row : List (H.Html msg) -> H.Html msg
row ads =
  H.div
    [ A.class "row list-ads__row" ]
    ads

adListView : User -> Models.Ad.Ad -> H.Html (ViewMessage msg)
adListView user ad =
  H.div
    [ A.class "col-xs-12 col-sm-6 list-ads__item-container"
    ]
    [ H.div
      [ A.class "list-ads__ad-preview list-ads__item" ] <|
      [ H.a
        [ A.href (Nav.routeToPath (Nav.ShowAd ad.id))
        , Link.action (Nav.ShowAd ad.id)
        , A.class "card-link list-ads__item-expanding-part"
        ]
        [ Ad.viewDate ad.createdAt
        , H.h3
          [ A.class "list-ads__ad-preview-heading"]
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
              [ H.text << toString <| Models.Ad.adCount ad.answers]
          , SvgIcons.answers
          ]
        , H.div [ A.class "list-ads__ad-preview-author-info" ] [ Common.authorInfo ad.createdBy ]
        ]
      ] ++
        if user.id == ad.createdBy.id then
          [ H.img
            [ A.class "list-ads__ad-preview-delete"
            , A.src "/static/close.svg"
            ]
            []
          ]
        else
          []
    ]
