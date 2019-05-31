module Profile.Membership exposing (dataInfo)

import Html as H
import Html.Attributes as A
import Translation exposing (T)


dataInfo : T -> H.Html msg
dataInfo t =
    H.div
        [ A.class "profile__editing--membership--info col-md-6" ]
        [ H.p
            [ A.class "profile__editing--membership--info--text" ]
            [ H.text <| t "profile.membershipInfo.profileUsesMembershipInfo"
            , H.span [ A.class "profile__editing--bold" ]
                [ H.text <| t "profile.membershipInfo.notVisibleAsIs"
                ]
            ]
        , H.a
            [ A.href "https://asiointi.tral.fi"
            , A.target "_blank"
            ]
            [ H.button
                [ A.class "profile__editing--membership--info--button btn btn-primary" ]
                [ H.text <| t "profile.membershipInfo.buttonUpdateInfo"
                ]
            ]
        ]
