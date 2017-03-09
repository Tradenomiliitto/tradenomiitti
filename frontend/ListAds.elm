module ListAds exposing (..)

import Html as H
import Html.Attributes as A
import Http
import Ad
import State.ListAds exposing (..)

type Msg = NoOp | GetAds | UpdateAds (Result Http.Error (List Ad.Ad))


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
      (model, Cmd.none)
    
{--
getAds : Cmd Msg
getAds =
  let
    url = "/api/ads/"
    request = Http.get url 
  in
    Http.send UpdateAds request
    
--}
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



adListView : Ad.Ad -> H.Html Msg
adListView ad = 
  H.div
    [ A.class "col-xs-12 col-sm-6"]
    [ H.div
      [ A.class "list-ads__ad-preview" ]
      [ H.h3 [ A.class "list-ads__ad-preview-heading" ] [ H.text ad.heading ]
      , H.p [ A.class "list-ads__ad-preview-content" ] [ H.text ad.content]
      , H.hr [] []
      , H.div
        []
        [ H.span [ A.class "list-ads__ad-preview-profile-pic" ] []
        , H.span
          [ A.class "list-ads__ad-preview-profile-info" ]
          [ H.span [ A.class "list-ads__ad-preview-profile-name"] [ H.text ad.createdBy.name ]
          , H.br [] []
          , H.span [ A.class "list-ads__ad-preview-profile-title"] [ H.text ad.createdBy.primaryPosition ]
          ]
        ]
      ]
    ]
  