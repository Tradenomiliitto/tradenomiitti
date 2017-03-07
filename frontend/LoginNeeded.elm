module LoginNeeded exposing (view)

import Html as H
import Html.Attributes as A

view : String -> H.Html msg
view loginUrl =
  H.div
    [ A.class "container"
    ]
    [ H.div
      [ A.class "row login-needed" ]
      [ H.div
        [ A.class "col-xs-11 col-sm-7 center-block login-needed__box" ]
        [ H.h1 [] [ H.text "Kirjaudu sisään" ]
        , H.p [] [ H.text "Tradenomiitti on ainutlaatuinen ja xxxxxxxxxxxxxxxxxxxxxxxx kohtaamispaikka, joten sinun tulee kirjautua sisään jättääksesi ilmoituksen muille tradenomeille."]
        , H.div
          [ A.class "login-needed__actionable-items" ]
          [ H.div [ A.class "login-needed__actionable-items-join" ]
              [ H.span [] [ H.text "Etkö ole vielä TRAL:n jäsen?" ]
              , H.span
                [ A.class "login-needed__actionable-items-join-link"]
                [ H.a [ A.href "http://tral.fi"] [ H.text "Liity jäseneksi" ] ]
              ]
          , H.div
            [ A.class "login-needed__actionable-items-login"
            ]
            [ H.a
                [ A.class "btn btn-primary btn-lg login-needed__actionable-items-login-button"
                , A.href loginUrl
                ]
                [ H.text "Kirjaudu" ] ]
          ]
        ]
      ]
    ]
