import Html as H
import Html.Attributes as A
import User

type Msg = NoOp

adListView : String -> String -> User.User -> H.Html Msg
adListView heading content user = 
  H.div
    [ A.class "col-xs-12 col-sm-6"]
    [ H.div
      [ A.class "user-page__activity-item" ]
      [ H.h3 [ A.class "user-page__activity-item-heading" ] [ H.text heading ]
      , H.p [ A.class "user-page__activity-item-content" ] [ H.text content]
      , H.hr [] []
      , H.div
        []
        [ H.span [ A.class "user-page__activity-item-profile-pic" ] []
        , H.span
          [ A.class "user-page__activity-item-profile-info" ]
          [ H.span [ A.class "user-page__activity-item-profile-name"] [ H.text user.name ]
          , H.br [] []
          , H.span [ A.class "user-page__activity-item-profile-title"] [ H.text user.primaryPosition ]
          ]
        ]
      ]
    ]
  