module Ad exposing (Msg(..), getAd, leaveAnswer, leaveAnswerBox, leaveAnswerPrompt, sendAnswer, update, view, viewAd, viewAnswer, viewAnswerCount, viewAnswerList, viewAnswers, viewDate)

import Common
import Date
import Html as H
import Html.Attributes as A
import Html.Events as E
import Http
import Json.Decode as Json
import Json.Encode as JS
import Link
import Maybe.Extra as Maybe
import Models.Ad exposing (Ad, Answer, Answers(..))
import Models.User exposing (User)
import Nav
import PlainTextFormat
import Removal
import State.Ad exposing (..)
import State.Util exposing (SendingStatus(..))
import Time
import Translation exposing (T)
import Util exposing (UpdateMessage(..), ViewMessage(..))


type Msg
    = StartAddAnswer
    | ChangeAnswerText String
    | SendAnswer Int
    | SendAnswerResponse Int (Result Http.Error String)
    | GetAd Ad
    | RemovalMessage Removal.Msg


getAd : Int -> Cmd (UpdateMessage Msg)
getAd adId =
    Http.get ("/api/ilmoitukset/" ++ String.fromInt adId) Models.Ad.adDecoder
        |> Util.errorHandlingSend GetAd


sendAnswer : Model -> Int -> Cmd (UpdateMessage Msg)
sendAnswer model adId =
    let
        encoded =
            JS.object
                [ ( "content", JS.string model.answerText ) ]
    in
    Http.post ("/api/ilmoitukset/" ++ String.fromInt adId ++ "/vastaus") (Http.jsonBody encoded) Json.string
        |> Http.send (LocalUpdateMessage << SendAnswerResponse adId)


update : Msg -> Model -> ( Model, Cmd (UpdateMessage Msg) )
update msg model =
    case msg of
        StartAddAnswer ->
            ( { model | addingAnswer = True }
            , Cmd.none
            )

        ChangeAnswerText str ->
            ( { model | answerText = str }
            , Cmd.none
            )

        SendAnswer adId ->
            ( { model | sending = Sending }
            , sendAnswer model adId
            )

        SendAnswerResponse adId (Ok _) ->
            ( { model
                | sending = FinishedSuccess "ok"
                , answerText = ""
                , addingAnswer = False
              }
            , getAd adId
            )

        SendAnswerResponse adId (Err _) ->
            ( { model | sending = FinishedFail }
            , Cmd.none
            )

        GetAd ad ->
            ( { model | ad = Just ad }
            , Cmd.none
            )

        RemovalMessage innerMsg ->
            let
                ( newRemoval, cmd ) =
                    Removal.update innerMsg model.removal
            in
            ( { model | removal = newRemoval }
            , Util.localMap RemovalMessage cmd
            )


view : T -> Model -> Int -> Maybe User -> String -> Time.Zone -> H.Html (ViewMessage Msg)
view t model adId user rootUrl timeZone =
    model.ad
        |> Maybe.map (viewAd t adId model user rootUrl timeZone)
        |> Maybe.withDefault (H.div [] [ H.text <| t "ad.requestFailed" ])


viewAd : T -> Int -> Model -> Maybe User -> String -> Time.Zone -> Ad -> H.Html (ViewMessage Msg)
viewAd t adId model userMaybe rootUrl timeZone ad =
    let
        loggedIn =
            Maybe.isJust userMaybe

        ( canAnswer, isAsker, hasAnswered ) =
            case userMaybe of
                Just user ->
                    let
                        isAskerInner =
                            ad.createdBy.id == user.id

                        hasAnsweredInner =
                            case ad.answers of
                                AnswerCount _ ->
                                    False

                                -- not logged in? shouldn't happen
                                AnswerList answers ->
                                    answers
                                        |> List.map (.id << .createdBy)
                                        |> List.any ((==) user.id)
                    in
                    ( not isAskerInner && not hasAnsweredInner, isAskerInner, hasAnsweredInner )

                Nothing ->
                    ( False, False, False )

        domainColumn =
            let
                items =
                    List.filterMap identity [ ad.domain, ad.position ]
            in
            if List.length items > 0 then
                [ H.div
                    [ A.class "col-xs-12 col-sm-8" ]
                    [ H.p [ A.class "ad-page__domains" ]
                        [ H.text << String.join "; " <| items ]
                    ]
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
                    [ viewDate t timeZone ad.createdAt
                    , H.h1 [ A.class "user-page__activity-item-heading" ] [ H.text ad.heading ]
                    , H.p [ A.class "user-page__activity-item-content" ] (PlainTextFormat.view ad.content)
                    , H.hr [] []
                    , H.div
                        [ A.class "row" ]
                        (domainColumn ++ locationColumn)
                    , H.hr [] []
                    , Common.authorInfo ad.createdBy
                    ]
                , leaveAnswer <|
                    if model.addingAnswer then
                        List.map (H.map LocalViewMessage) <| leaveAnswerBox t (model.sending == Sending) model.answerText adId

                    else
                        leaveAnswerPrompt t canAnswer isAsker hasAnswered loggedIn adId
                ]
            ]
        , H.hr [ A.class "full-width-ruler" ] []
        , H.div
            [ A.class "container last-row" ]
            [ viewAnswers t userMaybe model ad.answers adId rootUrl timeZone ]
        ]


viewAnswers : T -> Maybe User -> Model -> Answers -> Int -> String -> Time.Zone -> H.Html (ViewMessage Msg)
viewAnswers t userMaybe model answers adId rootUrl timeZone =
    case answers of
        AnswerCount num ->
            viewAnswerCount t num adId rootUrl

        AnswerList (fst :: rst) ->
            viewAnswerList t userMaybe model (fst :: rst) timeZone

        AnswerList _ ->
            H.div
                [ A.class "ad-page__answers" ]
                [ H.h1 [] [ H.text <| t "ad.noAnswersYet" ]
                , H.p [] [ H.text <| t "ad.noAnswersHint" ]
                ]


viewAnswerList : T -> Maybe User -> Model -> List Answer -> Time.Zone -> H.Html (ViewMessage Msg)
viewAnswerList t userMaybe model answers timeZone =
    H.div
        [ A.class "ad-page__answers" ]
        (List.indexedMap (\i answer -> viewAnswer t userMaybe model answer (modBy 2 (i + 1) == 0) timeZone i) answers)


viewAnswer : T -> Maybe User -> Model -> Answer -> Bool -> Time.Zone -> Int -> H.Html (ViewMessage Msg)
viewAnswer t userMaybe model answer isEven timeZone zerobasedIndex =
    H.div
        [ A.class "row ad-page__answers-row" ]
        [ H.div
            [ A.classList
                [ ( "col-sm-6", True )
                , ( "col-sm-offset-6", isEven )
                , ( "col-xs-11", True )
                , ( "col-xs-offset-1", isEven )
                , ( "ad-page__answers-row--left", not isEven )
                , ( "ad-page__answers-row--right", isEven )
                ]
            ]
            [ H.div
                [ A.classList
                    [ ( "ad-page__answers-content", True )
                    , ( "ad-page__answers-content--left", not isEven )
                    , ( "ad-page__answers-content--right", isEven )
                    ]
                ]
              <|
                [ viewDate t timeZone answer.createdAt
                , H.hr [] []
                , H.p [] (PlainTextFormat.view answer.content)
                , Common.authorInfo answer.createdBy
                , Util.localViewMap RemovalMessage <|
                    H.div
                        [ A.classList
                            [ ( "ad-page__answers-delete", True )
                            , ( "ad-page__answers-delete--left", not isEven )
                            , ( "ad-page__answers-delete--right", isEven )
                            ]
                        ]
                        (Removal.view t userMaybe zerobasedIndex answer model.removal)
                ]
            , H.span
                [ A.classList
                    [ ( "ad-page__answers-icon", True )
                    , ( "ad-page__answers-icon--left", not isEven )
                    , ( "ad-page__answers-icon--right", isEven )
                    , ( "glyphicon", True )
                    , ( "glyphicon-comment", True )
                    ]
                ]
                []
            ]
        ]


viewAnswerCount : T -> Int -> Int -> String -> H.Html msg
viewAnswerCount t num adId rootUrl =
    let
        ( heading, text ) =
            case num of
                0 ->
                    ( t "ad.answerCount.0.heading"
                    , t "ad.answerCount.0.hint"
                    )

                1 ->
                    ( t "ad.answerCount.1.heading"
                    , t "ad.answerCount.1.hint"
                    )

                n ->
                    ( t "ad.answerCount.n.heading"
                        |> Translation.replaceWith [ String.fromInt n ]
                    , t "ad.answerCount.n.hint"
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
            [ H.text <| t "common.login" ]
        ]


leaveAnswerBox : T -> Bool -> String -> Int -> List (H.Html Msg)
leaveAnswerBox t sending text adId =
    [ H.div
        [ A.class "ad-page__leave-answer-input-container" ]
        [ H.textarea
            [ A.class "ad-page__leave-answer-box"
            , A.placeholder <| t "ad.leaveAnswerBox.placeholder"
            , E.onInput ChangeAnswerText
            , A.disabled sending
            , A.value text
            ]
            []
        , Common.lengthHint t "ad-page__leave-answer-hint" text 5 1000
        , if not sending then
            H.button
                [ A.class "btn btn-primary ad-page__leave-answer-button"
                , E.onClick (SendAnswer adId)
                , A.disabled (String.length text < 5 || String.length text > 1000)
                ]
                [ H.text <| t "ad.leaveAnswerBox.submit" ]

          else
            H.div [ A.class "ad-page__sending" ] []
        ]
    ]


leaveAnswerPrompt : T -> Bool -> Bool -> Bool -> Bool -> Int -> List (H.Html (ViewMessage Msg))
leaveAnswerPrompt t canAnswer isAsker hasAnswered loggedIn adId =
    [ H.p
        [ A.class "ad-page__leave-answer-text" ]
        [ H.text <| t "ad.leaveAnswerPrompt.hint" ]
    , H.button
        [ A.class "btn btn-primary btn-lg ad-page__leave-answer-button"
        , if loggedIn then
            E.onClick (LocalViewMessage StartAddAnswer)

          else
            Link.action (Nav.LoginNeeded (Nav.ShowAd adId |> Nav.routeToPath |> Just))
        , A.title <|
            t
                "ad.leaveAnswerPrompt.answerTooltip"
        ]
        [ H.text <| t "ad.leaveAnswerPrompt.submit" ]
    ]


leaveAnswer : List (H.Html (ViewMessage Msg)) -> H.Html (ViewMessage Msg)
leaveAnswer contents =
    H.div
        [ A.class "col-xs-12 col-sm-6 ad-page__leave-answer" ]
        contents


viewDate : T -> Time.Zone -> Time.Posix -> H.Html msg
viewDate t timeZone date =
    H.p [ A.class "ad-page__date" ] [ H.text (Date.format (t "common.dateFormat") <| Date.fromPosix timeZone date) ]
