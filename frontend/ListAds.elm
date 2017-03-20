module ListAds exposing (..)

import Common
import Html as H
import Html.Attributes as A
import Html.Events as E
import Http
import Link exposing (AppMessage(..))
import Json.Decode as Json
import Models.Ad
import Nav
import State.ListAds exposing (..)

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
