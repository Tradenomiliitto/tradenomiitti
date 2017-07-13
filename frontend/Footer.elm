module Footer exposing (..)

import Common
import Html as H
import Html.Attributes as A
import Models.User exposing (User)
import Nav


view : (Nav.Route -> msg) -> Maybe User -> H.Html msg
view routeToMsg userMaybe =
    H.div
        [ A.class "footer" ]
        [ H.div
            [ A.class "container footer__content" ]
            [ H.div [ A.class "row" ]
                [ H.div
                    [ A.class "col-xs-12 col-sm-3" ]
                    [ H.img
                        [ A.src "/static/footer_logo.png"
                        , A.class "footer__logo"
                        ]
                        []
                    ]
                , H.div
                    [ A.class "col-xs-12 col-sm-3" ]
                  <|
                    [ H.p [] [ Common.link Nav.Terms routeToMsg ]
                    , H.p [] [ Common.link Nav.RegisterDescription routeToMsg ]
                    , H.p [] [ H.a [ A.href "http://tral.fi" ] [ H.text "tral.fi" ] ]
                    , H.p [] [ H.a [ A.href "http://liity.tral.fi/#liity" ] [ H.text "Liity jäseneksi" ] ]
                    , H.p [] [ H.a [ A.href "mailto:tradenomiitti@tral.fi" ] [ H.text "Anna palautetta" ] ]
                    ]
                        ++ (if Models.User.isAdmin userMaybe then
                                [ H.p
                                    [ A.class "footer__admin-link" ]
                                    [ H.a
                                        [ A.href "/api/raportti"
                                        , A.downloadAs "raportti.csv"
                                        ]
                                        [ H.text "Tilastoja" ]
                                    ]
                                ]
                            else
                                []
                           )
                , H.div
                    [ A.class "col-xs-12 col-sm-6 footer__social-icons" ]
                    [ H.a [ A.href "https://www.facebook.com/tradenomiliitto" ] [ H.i [ A.class "fa fa-facebook" ] [] ]
                    , H.a [ A.href "https://twitter.com/Tradenomiliitto" ] [ H.i [ A.class "fa fa-twitter" ] [] ]
                    , H.a [ A.href "https://www.instagram.com/tradenomiliitto/" ] [ H.i [ A.class "fa fa-instagram" ] [] ]
                    , H.a [ A.href "http://www.linkedin.com/groups/Tradenomiliitto-TRAL-ry-2854058/about" ] [ H.i [ A.class "fa fa-linkedin" ] [] ]
                    , H.a [ A.href "https://github.com/tradenomiliitto/tradenomiitti" ] [ H.i [ A.class "fa fa-github" ] [] ]
                    ]
                ]
            ]
        ]
