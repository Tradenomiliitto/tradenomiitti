module LoginNeeded exposing (view)

import Html as H
import Html.Attributes as A
import Nav
import Translation exposing (T)


view : T -> String -> H.Html msg
view t loginUrl =
    H.div
        [ A.class "login-needed__container"
        ]
        [ H.canvas
            [ A.id "login-needed-canvas"
            , A.class "login-needed__animation"
            ]
            []
        , viewLoginBox t loginUrl
        ]


viewLoginBox : T -> String -> H.Html msg
viewLoginBox t loginUrl =
    let
        t_ key =
            t ("loginNeeded." ++ key)
    in
    H.div
        [ A.class "container"
        ]
        [ H.div
            [ A.class "row login-needed" ]
            [ H.div
                [ A.class "col-xs-11 col-sm-7 center-block login-needed__box" ]
                [ H.h1 [] [ H.text <| t_ "heading" ]
                , H.p [] [ H.text <| t_ "info" ]
                , H.div
                    [ A.class "login-needed__actionable-items" ]
                    [ H.div
                        [ A.class "login-needed__actionable-items-login"
                        ]
                        [ H.a
                            [ A.class "btn btn-primary btn-lg login-needed__actionable-items-button"
                            , A.href (Nav.routeToPath Nav.Registration)
                            ]
                            [ H.text <| t_ "registerButton" ]
                        ]
                    , H.div
                        [ A.class "login-needed__actionable-items-login"
                        ]
                        [ H.a
                            [ A.class "btn btn-primary btn-lg login-needed__actionable-items-button"
                            , A.href loginUrl
                            ]
                            [ H.text <| t "common.login" ]
                        ]
                    ]
                ]
            ]
        ]
