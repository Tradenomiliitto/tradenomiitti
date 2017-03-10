module ListAds exposing (..)

import Common
import Ad
import Html as H
import Html.Attributes as A
import Http
import Json.Decode exposing (list)
import State.Ad
import State.ListAds exposing (..)

type Msg = NoOp | GetAds | UpdateAds (Result Http.Error (List State.Ad.Ad))


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    NoOp ->
      (model, Cmd.none)
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
    url = "/api/ads/"
    request = Http.get url (list Ad.adDecoder)
  in
    Http.send UpdateAds request


view : Model -> H.Html Msg
view model =
  H.div []
  [ H.div
    []
    [ H.h3 [ A.class "list-ads__header" ] [ H.text "Selaa hakuilmoituksia" ] ]
  , H.div [A.class "list-ads__list-background"]
    [ H.div
      [ A.class "row list-ads__ad-container" ]
      (List.map
        adListView
        model.ads) ]
  ]



adListView : State.Ad.Ad -> H.Html Msg
adListView ad =
  H.div
    [ A.class "col-xs-12 col-sm-6"]
    [ H.div
      [ A.class "list-ads__ad-preview" ]
      [ H.h3 []
        [ H.a 
          [ A.class "list-ads__ad-preview-heading"
          , A.href ("/ads/" ++ (toString ad.id)) ]
          [ H.text ad.heading ] 
        ]
      , H.p [ A.class "list-ads__ad-preview-content" ] [ H.text (truncateContent ad.content 200) ]
      , H.hr [] []
      , Common.authorInfo ad.createdBy
      ]
    ]

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
