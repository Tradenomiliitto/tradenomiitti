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
import Models.Ad exposing (Ad, Answers(..), Answer)
import Models.User exposing (User)
import Nav
import State.Ad exposing (..)
import State.Util exposing (SendingStatus(..))
import Util exposing (UpdateMessage(..))

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

view : Model -> Int -> Maybe User -> String -> H.Html Msg
view model adId user rootUrl =
  model.ad
    |> Maybe.map (viewAd adId model user rootUrl)
    |> Maybe.withDefault (H.div [] [ H.text "Ilmoituksen haku epäonnistui" ])

viewAd : Int -> Model -> Maybe User -> String -> Ad -> H.Html Msg
viewAd adId model userMaybe rootUrl ad =
  let
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
  in
    H.div
      [ A.class "container ad-page" ]
      [ H.div
        [ A.class "row ad-page__ad-container" ]
        [ H.div
          [ A.class "col-xs-12 col-sm-6 ad-page__ad" ]
          [ viewDate ad.createdAt
          , H.h1 [ A.class "user-page__activity-item-heading" ] [ H.text ad.heading ]
          , H.p [ A.class "user-page__activity-item-content" ]  [ H.text ad.content ]
          , H.hr [] []
          , Common.authorInfo ad.createdBy
          ]
        , leaveAnswer <|
          if model.addingAnswer
          then leaveAnswerBox (model.sending == Sending) adId
          else leaveAnswerPrompt canAnswer isAsker hasAnswered
        ]
      , H.hr [ A.class "full-width-ruler" ] []
      , viewAnswers ad.answers adId rootUrl
      ]


viewAnswers : Answers -> Int -> String -> H.Html Msg
viewAnswers answers adId rootUrl =
  case answers of
    AnswerCount num ->
      viewAnswerCount num adId rootUrl
    AnswerList (fst :: rst) ->
      viewAnswerList (fst :: rst)
    AnswerList _ ->
      H.div
        [ A.class "ad-page__answers" ]
        [ H.h1 [] [ H.text "Tällä ilmoituksella ei ole vielä yhtään vastausta" ]
        , H.p [] [ H.text "Lisää omasi ylhäällä" ]
        ]

viewAnswerList : List Answer -> H.Html Msg
viewAnswerList answers =
  H.div
    [ A.class "ad-page__answers" ]
    (List.indexedMap (\i answer -> viewAnswer answer ((i+1) % 2 == 0)) answers)

viewAnswer : Answer -> Bool -> H.Html Msg
viewAnswer answer isEven =
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
          ]
          [ viewDate answer.createdAt
          , H.hr [] []
          , H.p [] [ H.text answer.content ]
          , Common.authorInfo answer.createdBy
          ]
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

viewAnswerCount : Int -> Int -> String -> H.Html Msg
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


leaveAnswerBox : Bool -> Int -> List (H.Html Msg)
leaveAnswerBox sending adId =
  [ H.div
    [ A.class "ad-page__leave-answer-input-container" ]
    [ H.textarea
        [ A.class "ad-page__leave-answer-box"
        , A.placeholder "Kirjoita napakka vastaus"
        , E.onInput ChangeAnswerText
        , A.disabled sending
        ]
        []
    , if not sending
      then
        H.button
          [ A.class "btn btn-primary ad-page__leave-answer-button"
          , E.onClick (SendAnswer adId)
          ]
          [ H.text "Jätä vastaus" ]
      else
        H.div [ A.class "ad-page__sending"] []
    ]
  ]

leaveAnswerPrompt : Bool -> Bool -> Bool -> List (H.Html Msg)
leaveAnswerPrompt canAnswer isAsker hasAnswered =
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
        , E.onClick StartAddAnswer
        , A.disabled (not canAnswer)
        , A.title (if canAnswer
                  then "Voit vastata muiden esittämiin kysymyksiin kerran"
                  else "Et voi vastata tähän kysymykseen")
        ]
        [ H.text "Vastaa ilmoitukseen" ]
      ]

leaveAnswer : List (H.Html Msg) -> H.Html Msg
leaveAnswer contents =
  H.div
    [ A.class "col-xs-12 col-sm-6 ad-page__leave-answer" ]
    contents

viewDate : Date.Date -> H.Html Msg
viewDate date =
  H.p [ A.class "ad-page__date" ] [ H.text (Date.toFormattedString "d.M.y" date) ]
