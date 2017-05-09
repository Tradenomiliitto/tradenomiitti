module Ad exposing (..)

import Common
import Date
import Date.Extra as Date
import Html as H
import Html.Attributes as A
import Html.Events as E
import Http
import Json.Decode as Json
import Json.Encode as JS
import Link
import Maybe.Extra as Maybe
import Models.Ad exposing (Ad, Answers(..), Answer)
import Models.User exposing (User)
import Nav
import State.Ad exposing (..)
import State.Util exposing (SendingStatus(..))
import Util exposing (UpdateMessage(..), ViewMessage(..))

type Msg
  = StartAddAnswer
  | ChangeAnswerText String
  | SendAnswer Int
  | SendAnswerResponse Int (Result Http.Error String)
  | GetAd Ad


getAd : Int -> Cmd (UpdateMessage Msg)
getAd adId =
  Http.get ("/api/ilmoitukset/" ++ toString adId) Models.Ad.adDecoder
    |> Util.errorHandlingSend GetAd

sendAnswer : Model -> Int -> Cmd (UpdateMessage Msg)
sendAnswer model adId =
  let
    encoded =
      JS.object
        [ ("content", JS.string model.answerText)]
  in
    Http.post ("/api/ilmoitukset/" ++ toString adId ++ "/vastaus") (Http.jsonBody encoded) Json.string
      |> Http.send (LocalUpdateMessage << SendAnswerResponse adId)


update : Msg -> Model -> (Model, Cmd (UpdateMessage Msg))
update msg model =
  case msg of
    StartAddAnswer ->
      { model | addingAnswer = True } ! []

    ChangeAnswerText str ->
      { model | answerText = str } ! []

    SendAnswer adId ->
      { model | sending = Sending } ! [ sendAnswer model adId ]

    SendAnswerResponse adId (Ok _) ->
      { model
        | sending = FinishedSuccess "ok"
        , answerText = ""
        , addingAnswer = False
      } ! [ getAd adId ]

    SendAnswerResponse adId (Err _) ->
      { model | sending = FinishedFail } ! []

    GetAd ad ->
      { model | ad = Just ad } ! []

view : Model -> Int -> Maybe User -> String -> H.Html (ViewMessage Msg)
view model adId user rootUrl =
  model.ad
    |> Maybe.map (viewAd adId model user rootUrl)
    |> Maybe.withDefault (H.div [] [ H.text "Ilmoituksen haku epäonnistui" ])

viewAd : Int -> Model -> Maybe User -> String -> Ad -> H.Html (ViewMessage Msg)
viewAd adId model userMaybe rootUrl ad =
  let
    loggedIn = Maybe.isJust userMaybe
    (canAnswer, isAsker, hasAnswered) =
      case userMaybe of
        Just user ->
          let
            isAsker = ad.createdBy.id == user.id
            hasAnswered =
              case ad.answers of
                AnswerCount _ -> (False) -- not logged in? shouldn't happen
                AnswerList answers ->
                  answers
                    |> List.map (.id << .createdBy)
                    |> List.any ((==) user.id)
          in
            (not isAsker && not hasAnswered, isAsker, hasAnswered)

        Nothing ->
          (False, False, False)
    domainColumn =
      let
       items = List.filterMap identity [ ad.domain, ad.position ]
      in
        if List.length items > 0
        then
          [ H.div
            [ A.class "col-xs-12 col-sm-8" ]
            [ H.p [ A.class "ad-page__domains" ]
              [ H.text << String.join "; " <| items ]]
          ]
        else
          []

    locationColumn =
      ad.location
        |> Maybe.map
          (\location ->
             [ H.div
               [ A.class "col-xs-12 col-sm-4" ]
               [ Common.showLocation location
               ]
             ]
          )
        |> Maybe.withDefault []
  in
    H.div
      []
      [ H.div
        [ A.class "container ad-page" ]
        [ H.div
          [ A.class "row ad-page__ad-container" ]
          [ H.div
            [ A.class "col-xs-12 col-sm-6 ad-page__ad" ]
            [ viewDate ad.createdAt
            , H.h1 [ A.class "user-page__activity-item-heading" ] [ H.text ad.heading ]
            , H.p [ A.class "user-page__activity-item-content" ]  [ H.text ad.content ]
            , H.hr [] []
            , H.div
              [ A.class "row" ]
              (domainColumn ++ locationColumn)
            , H.hr [] []
            , Common.authorInfo ad.createdBy
            ]
          , leaveAnswer <|
            if model.addingAnswer
            then List.map (H.map LocalViewMessage) <| leaveAnswerBox (model.sending == Sending) model.answerText adId
            else leaveAnswerPrompt canAnswer isAsker hasAnswered loggedIn adId
          ]
        ]
      , H.hr [ A.class "full-width-ruler" ] []
      , H.div
        [ A.class "container last-row"]
        [ viewAnswers userMaybe ad.answers adId rootUrl ]
      ]


viewAnswers : Maybe User -> Answers -> Int -> String -> H.Html (ViewMessage Msg)
viewAnswers userMaybe answers adId rootUrl =
  case answers of
    AnswerCount num ->
      viewAnswerCount num adId rootUrl
    AnswerList (fst :: rst) ->
      viewAnswerList userMaybe (fst :: rst)
    AnswerList _ ->
      H.div
        [ A.class "ad-page__answers" ]
        [ H.h1 [] [ H.text "Tällä ilmoituksella ei ole vielä yhtään vastausta" ]
        , H.p [] [ H.text "Lisää omasi ylhäällä" ]
        ]

viewAnswerList : Maybe User -> List Answer -> H.Html (ViewMessage Msg)
viewAnswerList userMaybe answers =
  H.div
    [ A.class "ad-page__answers" ]
    (List.indexedMap (\i answer -> (viewAnswer userMaybe) answer ((i+1) % 2 == 0)) answers)

viewAnswer : Maybe User -> Answer -> Bool -> H.Html (ViewMessage Msg)
viewAnswer userMaybe answer isEven =
  H.div
    [ A.class "row ad-page__answers-row" ] <|
    (if isEven then List.reverse else identity)
    [ H.div
      [ A.classList
        [ ("col-sm-6", True)
        , ("col-sm-offset-6", isEven)
        , ("ad-page__answers-row--left", not isEven)
        , ("ad-page__answers-row--right", isEven)
        ]
      ]
      [ H.div
          [ A.classList
              [ ("ad-page__answers-content", True)
              , ("ad-page__answers-content--left", not isEven)
              , ("ad-page__answers-content--right", isEven)
              ]
          ] <|
          [ viewDate answer.createdAt
          , H.hr [] []
          , H.p [] [ H.text answer.content ]
          , Common.authorInfo answer.createdBy
          ] ++
          if Maybe.map .id userMaybe == Just answer.createdBy.id then
            [ H.img
              [ A.classList
                  [ ("ad-page__answers-delete", True)
                  , ("ad-page__answers-delete--left", not isEven)
                  , ("ad-page__answers-delete--right", isEven)
                  ]
              , A.src "/static/close.svg"
              ]
              []
            ]
        else
          []
      , H.span
        [ A.classList
            [ ("ad-page__answers-icon", True)
            , ("ad-page__answers-icon--left", not isEven)
            , ("ad-page__answers-icon--right", isEven)
            , ("glyphicon", True)
            , ("glyphicon-comment", True)
            ]
        ]
        []
      ]
    ]

viewAnswerCount : Int -> Int -> String -> H.Html msg
viewAnswerCount num adId rootUrl =
  let
    (heading, text) =
      case num of
        0 ->
          ( "Tähän ilmoitukseen ei ole vastattu kertaakaan"
          , "Kirjaudu sisään ja ole ensimmäinen"
          )
        1 ->
          ( "Tällä ilmoituksella on yksi vastaus"
          , "Kirjaudu sisään nähdäksesesi sen ja lisää omasi"
          )
        n ->
          ( "Tähän ilmoitukseen on vastattu " ++ toString n ++ " kertaa"
          , "Kirjaudu sisään nähdäksesi vastaukset ja lisää omasi"
          )
  in
    H.div
      [ A.class "ad-page__answers" ]
      [ H.h1 [] [ H.text heading ]
      , H.p [] [ H.text text ]
      , H.a
        [ A.class "btn btn-primary"
        , A.href (Nav.ssoUrl rootUrl (Nav.ShowAd adId |> Nav.routeToPath |> Just))
        ]
        [ H.text "Kirjaudu" ]
      ]


leaveAnswerBox : Bool -> String -> Int -> List (H.Html Msg)
leaveAnswerBox sending text adId =
  [ H.div
    [ A.class "ad-page__leave-answer-input-container" ]
    [ H.textarea
        [ A.class "ad-page__leave-answer-box"
        , A.placeholder "Kirjoita napakka vastaus"
        , E.onInput ChangeAnswerText
        , A.disabled sending
        , A.value text
        ]
        []
    , Common.lengthHint "ad-page__leave-answer-hint" text 10 1000
    , if not sending
      then
        H.button
          [ A.class "btn btn-primary ad-page__leave-answer-button"
          , E.onClick (SendAnswer adId)
          , A.disabled (String.length text < 10 || String.length text > 1000)
          ]
          [ H.text "Jätä vastaus" ]
      else
        H.div [ A.class "ad-page__sending"] []
    ]
  ]

leaveAnswerPrompt : Bool -> Bool -> Bool -> Bool -> Int -> List (H.Html (ViewMessage Msg))
leaveAnswerPrompt canAnswer isAsker hasAnswered loggedIn adId =
  if isAsker then
    [ H.p
      [ A.class "ad-page__leave-answer-text" ]
      [ H.text "Muut käyttäjät voivat vastata ilmoitukseesi tällä sivulla. Näet vastaukset alla kun niitä tulee." ]
    ]
  else
    if hasAnswered then
      [ H.p
        [ A.class "ad-page__leave-answer-text" ]
        [ H.text "Olet vastannut tähän ilmoitukseen. Kiitos kun autoit kanssatradenomiasi!" ]
      ]
    else
      [ H.p
          [ A.class "ad-page__leave-answer-text"]
          [ H.text "Kokemuksellasi on aina arvoa. Jaa näkemyksesi vastaamalla ilmoitukseen." ]
      , H.button
        [ A.class "btn btn-primary btn-lg ad-page__leave-answer-button"
        , if loggedIn then
            E.onClick (LocalViewMessage StartAddAnswer)
          else
            Link.action (Nav.LoginNeeded (Nav.ShowAd adId |> Nav.routeToPath |> Just))
        , A.disabled (not canAnswer && loggedIn)
        , A.title (if canAnswer || not loggedIn
                  then "Voit vastata muiden esittämiin kysymyksiin kerran"
                  else "Et voi vastata tähän kysymykseen")
        ]
        [ H.text "Vastaa ilmoitukseen" ]
      ]

leaveAnswer : List (H.Html (ViewMessage Msg)) -> H.Html (ViewMessage Msg)
leaveAnswer contents =
  H.div
    [ A.class "col-xs-12 col-sm-6 ad-page__leave-answer" ]
    contents

viewDate : Date.Date -> H.Html msg
viewDate date =
  H.p [ A.class "ad-page__date" ] [ H.text (Date.toFormattedString "d.M.y" date) ]
