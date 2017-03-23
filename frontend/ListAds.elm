module ListAds exposing (..)

import Common
import Html as H
import Html.Attributes as A
import Http
import Json.Decode as Json
import Link exposing (AppMessage(..))
import Models.Ad
import Nav
import State.ListAds exposing (..)
import Svg
import Svg.Attributes as SvgA

type Msg = GetAds | UpdateAds (Result Http.Error (List Models.Ad.Ad))


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    UpdateAds (Ok ads) ->
      ({ model | ads = ads }, Cmd.none )
    --TODO: show error
    UpdateAds (Err _) ->
      (model, Cmd.none)
    GetAds ->
      (model, getAds)


getAds : Cmd Msg
getAds =
  let
    url = "/api/ilmoitukset/"
    request = Http.get url (Json.list Models.Ad.adDecoder)
  in
    Http.send UpdateAds request


view : Model -> H.Html (AppMessage Msg)
view model =
  H.div []
    [ H.div
      [ A.class "container" ]
      [ H.div
        [ A.class "row" ]
        [ H.div
          [ A.class "col-sm-12" ]
          [ H.h3
            [ A.class "list-ads__header" ]
            [ H.text "Selaa hakuilmoituksia" ]
          ]
        ]
      ]
    , H.div
      [ A.class "list-ads__list-background"]
      [ H.div
        [ A.class "container" ]
        (viewAds model.ads)
      ]
    ]

viewAds : List Models.Ad.Ad -> List (H.Html (AppMessage msg))
viewAds ads =
  let
    adsHtml = List.map adListView ads
    rows = List.reverse (List.foldl rowFolder [] adsHtml)
    rowsHtml = List.map row rows
  in
    rowsHtml

row : List (H.Html msg) -> H.Html msg
row ads =
  H.div
    [ A.class "row" ]
    ads

adListView : Models.Ad.Ad -> H.Html (AppMessage msg)
adListView ad =
  H.a
    [ A.class "col-xs-12 col-sm-6 card-link"
    , A.href (Nav.routeToPath (Nav.ShowAd ad.id))
    , Link.action (Nav.ShowAd ad.id)]
    [ H.div
      [ A.class "list-ads__ad-preview" ]
      [ H.h3
        [ A.class "list-ads__ad-preview-heading"]
        [ H.text ad.heading ]
      , H.p [ A.class "list-ads__ad-preview-content" ] [ H.text (truncateContent ad.content 200) ]
      , H.hr [] []
      , H.div
        [ A.class "list-ads__ad-preview-answer-count" ]
        [ H.span
            [ A.class "list-ads__ad-preview-answer-count-number" ]
            [ H.text << toString <| Models.Ad.adCount ad.answers]
        , Svg.svg
          [ SvgA.viewBox "0 0 64 60"
          ]
          [ Svg.g
            []
            [ Svg.path
              [ SvgA.d "M12.2,55.6c-0.1,0-0.2,0-0.4-0.1c-0.4-0.2-0.6-0.5-0.6-0.9V45h-9c-0.6,0-1-0.4-1-1V10.9c0-0.6,0.4-1,1-1h55c0.6,0,1,0.4,1,1V44c0,0.6-0.4,1-1,1H22.6l-9.7,10.3C12.7,55.5,12.5,55.6,12.2,55.6z M3.2,43h9c0.6,0,1,0.4,1,1v8.1l8.3-8.8c0.2-0.2,0.5-0.3,0.7-0.3h34V11.9h-53V43z"
              ]
              []
            , Svg.rect
              [ SvgA.x "11.8"
              , SvgA.y "20.9"
              , SvgA.width "35"
              , SvgA.height "2"
              ] []
            , Svg.rect
              [ SvgA.x "11.8"
              , SvgA.y "29.9"
              , SvgA.width "35"
              , SvgA.height "2"
              ] []
            , Svg.path
              [ SvgA.d "M61.8,35.9h-5v-2h4v-28h-53v4h-2v-5c0-0.6,0.4-1,1-1h55c0.6,0,1,0.4,1,1v30C62.8,35.5,62.4,35.9,61.8,35.9z"
              ] []
            ]
          ]
        ]
      , Common.authorInfo ad.createdBy
      ]
    ]


-- transforms a list to a list of lists of two elements: [1, 2, 3, 4, 5] => [[5], [3, 4], [1, 2]]
-- note: reverse the results if you need the elements to be in original order
rowFolder : a -> List (List a) -> List (List a)
rowFolder x acc =
  case acc of
    [] -> [[x]]
    row :: rows ->
      case row of
        el1 :: el2 :: els -> [x] :: row :: rows
        el :: els -> [el, x] :: rows
        els -> (x :: els) :: rows

-- truncates content so that the result includes at most numChars characters, taking full words. "…" is added if the content is truncated
truncateContent : String -> Int -> String
truncateContent content numChars =
  if (String.length content) < numChars
    then content
    else
      let
        truncated = List.foldl (takeNChars numChars) "" (String.words content)
      in
        -- drop extra whitespace created by takeNChars and add three dots
        (String.dropRight 1 truncated) ++ "…"

-- takes first x words where sum of the characters is less than n
takeNChars : Int -> String -> String -> String
takeNChars n word accumulator =
  let
    totalLength = (String.length accumulator) + (String.length word)
  in
    if totalLength < n
      then accumulator ++ word ++ " "
      else accumulator
