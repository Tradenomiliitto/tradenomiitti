module Removal exposing (..)

import Html as H
import Html.Attributes as A
import Html.Events as E
import List.Extra as List
import Maybe.Extra as Maybe
import Models.User exposing (User)
import Navigation
import Util exposing (ViewMessage(..), UpdateMessage(..))

type Msg
  = InitiateRemove Int Int -- index id
  | CancelRemoval Int
  | ConfirmRemoval Int -- id to remove
  | SuccesfullyRemoved

type alias Model =
  { removals : List Removal
  , target : RemovalTarget
  }

type RemovalTarget = Ad | Answer

init : RemovalTarget -> Model
init target =
  { removals = []
  , target = target
  }

type alias Removal =
  { id : Int
  , index : Int
  }


deleteAd : Int -> Cmd (UpdateMessage Msg)
deleteAd id =
  Util.delete ("/api/ilmoitukset/" ++ toString id)
    |> Util.errorHandlingSend (always SuccesfullyRemoved)

deleteAnswer : Int -> Cmd (UpdateMessage Msg)
deleteAnswer id =
  Util.delete ("/api/vastaukset/" ++ toString id)
    |> Util.errorHandlingSend (always SuccesfullyRemoved)


update : Msg -> Model -> (Model, Cmd (UpdateMessage Msg))
update msg model =
  case msg of
    InitiateRemove index id ->
      { model | removals = { index = index, id = id } :: model.removals } ! []
    CancelRemoval index ->
      { model | removals =  List.filterNot (\removal -> removal.index == index) model.removals } ! []
    ConfirmRemoval id ->
      let
        cmd =
          case model.target of
            Ad -> deleteAd id
            Answer -> deleteAnswer id
      in
        model ! [ cmd ]
    SuccesfullyRemoved ->
      model ! [ Navigation.reload ]


type alias AdLike a =
  { a
    | id : Int
    , createdBy : User
  }

view : Maybe User -> Int -> AdLike a -> List Removal -> List (H.Html (ViewMessage Msg))
view userMaybe index ad removals =
  let
    icon =
      H.img
        [ A.class "removal__icon"
        , A.src "/static/close.svg"
        , A.title "Poista oma ilmoituksesi"
        , E.onClick << LocalViewMessage <| InitiateRemove index ad.id
        ]
        []
    isBeingRemoved =
      removals
        |> List.find (\removal -> removal.index == index)
        |> Maybe.isJust

    confirmationBox =
      H.div
        [ A.class "removal__confirmation"]
        [ H.p
          [ A.class "removal__confirmation-text"]
          [ H.text "Tämä poistaa ilmoituksen ja kaikki siihen tulleet vastaukset pysyvästi. Oletko varma?" ]
        , H.div
          [ A.class "removal__confirmation-buttons" ]
          [ H.button
            [ A.class "btn removal__confirmation-button-cancel"
            , E.onClick << LocalViewMessage <| CancelRemoval index
            ]
            [ H.text "Peru" ]
          , H.button
            [ A.class "btn btn-primary removal__confirmation-button-confirm"
            , E.onClick << LocalViewMessage <| ConfirmRemoval ad.id
            ]
            [ H.text "Haluan poistaa ilmoituksen" ]
          ]
        ]
  in
    if Maybe.map .id userMaybe == Just ad.createdBy.id then
      [ H.div
        [ A.class "removal" ]
        [ if not isBeingRemoved
          then icon
          else confirmationBox
        ]
      ]
    else
      []
