module Ad exposing (..)

import Date
import Html as H
import Html.Attributes as A
import Html.Events as E
import State.Ad exposing (..)
import User

type alias Ad =
  {
    heading: String,
    content: String,
    answers: Answers,
    createdBy: User.User,
    createdAt: Date.Date
  }

type Answers = AnswerCount Int | AnswerList (List Answer)

type alias Answer =
  {
    heading: String,
    content: String,
    createdBy: User.User,
    createdAt: Date.Date
  }

type Msg = StartAddAnswer

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    StartAddAnswer ->
      { model | addingAnswer = True } ! []

view : Model -> H.Html Msg
view model =
  H.div
    [ A.class "container ad-page" ]
    [ H.div
      [ A.class "row ad-page__ad-container" ]
      [ H.div
        [ A.class "col-xs-12 col-sm-6 ad-page__ad" ]
        [ H.p [ A.class "ad-page__date" ] [ H.text "8.3.2017" ] -- TODO
        , H.h3 [ A.class "user-page__activity-item-heading" ] [ H.text "Miten menestyä finanssialallla?" ] -- TODO
        , H.p [ A.class "user-page__activity-item-content" ]  [ H.text "Curabitur lacinia pulvinar nibh.  Aliquam feugiat tellus ut neque.  Nunc eleifend leo vitae magna.  Nullam libero mauris, consequat quis, varius et, dictum id, arcu.  Nullam rutrum.  Nunc aliquet, augue nec adipiscing interdum, lacus tellus malesuada massa, quis varius mi purus non odio.  Nam a sapien.  " ] -- TODO
        , H.hr [] []
        , H.div
          []
          [ H.span [ A.class "user-page__activity-item-profile-pic" ] []
          , H.span
            [ A.class "user-page__activity-item-profile-info" ]
            [ H.span [ A.class "user-page__activity-item-profile-name"] [ H.text "Matti" ]
            , H.br [] []
            , H.span [ A.class "user-page__activity-item-profile-title"] [ H.text "Titteli" ]
            ]
          ]
        ]
      , leaveAnswer <| if model.addingAnswer then leaveAnswerBox else leaveAnswerPrompt
      ]
    ]

leaveAnswerBox : List (H.Html Msg)
leaveAnswerBox =
  [ H.div
    [ A.class "ad-page__leave-answer-input-container"]
    [ H.textarea
        [ A.class "ad-page__leave-answer-box"
        , A.placeholder "Kirjoita napakka vastaus"
        ]
        []
    , H.button
      [ A.class "btn btn-primary ad-page__leave-answer-button" ]
      [ H.text "Jätä vastaus" ]
    ]
  ]

leaveAnswerPrompt : List (H.Html Msg)
leaveAnswerPrompt =
  [ H.p
      [ A.class "ad-page__leave-answer-text"]
      [ H.text "Kokemuksellasi on aina arvoa. Jää näkemyksesi vastaamalla ilmoitukseen." ]
  , H.button
    [ A.class "btn btn-primary btn-lg ad-page__leave-answer-button"
    , E.onClick StartAddAnswer
    ]
    [ H.text "Vastaa ilmoitukseen" ]
  ]

leaveAnswer : List (H.Html Msg) -> H.Html Msg
leaveAnswer contents =
  H.div
    [ A.class "col-xs-12 col-sm-6 ad-page__leave-answer" ]
    contents
