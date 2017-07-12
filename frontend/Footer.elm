module Footer exposing (..)

import Common
import Constants
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
                        [ A.src "/static/tral-logo_white.png"
                        , A.class "footer__tral-logo"
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
                    (List.map
                        (\{ url, faIcon } ->
                            H.a [ A.href url ] [ H.i [ A.class <| "fa fa-" ++ faIcon ] [] ]
                        )
                        Constants.footerSocialIcons
                    )
                ]
            ]
        ]
