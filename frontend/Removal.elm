module Removal exposing (..)

import Html as H
import Html.Attributes as A
import Html.Events as E
import List.Extra as List
import Maybe.Extra as Maybe
import Models.Ad
import Models.User exposing (User)
import Util exposing (ViewMessage(..), UpdateMessage(..))

type Msg
  = InitiateRemoveAd Int Models.Ad.Ad

type alias Model = List Removal

init : Model
init = []

type alias Removal =
  { adId : Int
  , index : Int
  }


update : Msg -> Model -> (Model, Cmd (UpdateMessage Msg))
update msg model =
  case msg of
    InitiateRemoveAd index ad ->
      ({ index = index, adId = ad.id } :: model) ! []


view : User -> Int -> Models.Ad.Ad -> List Removal -> List (H.Html (ViewMessage Msg))
view user index ad removals =
  let
    icon =
      H.img
        [ A.class "list-ads__ad-preview-delete-icon"
        , A.src "/static/close.svg"
        , A.title "Poista oma ilmoituksesi"
        , E.onClick << LocalViewMessage <| InitiateRemoveAd index ad
        ]
        []
    isBeingRemoved =
      removals
        |> List.find (\removal -> removal.index == index)
        |> Maybe.isJust

    confirmationBox =
      H.div
        [ A.class "list-ads__ad-preview-delete-confirmation"]
        [ H.p
          [ A.class "list-ads__ad-preview-delete-confirmation-text"]
          [ H.text "Tämä poistaa ilmoituksen ja kaikki siihen tulleet vastaukset pysyvästi. Oletko varma?" ]
        , H.div
          [ A.class "list-ads__ad-preview-delete-confirmation-buttons" ]
          [ H.button
            [ A.class "btn list-ads__ad-preview-delete-confirmation-button-cancel"]
            [ H.text "Peru" ]
          , H.button
            [ A.class "btn btn-primary list-ads__ad-preview-delete-confirmation-button-confirm" ]
            [ H.text "Haluan poistaa ilmoituksen" ]
          ]
        ]
  in
    if user.id == ad.createdBy.id then
      [ H.div
        [ A.class "list-ads__ad-preview-delete" ]
        [ if not isBeingRemoved
          then icon
          else confirmationBox
        ]
      ]
    else
      []
