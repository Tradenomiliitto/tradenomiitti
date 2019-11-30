module Profile.Membership exposing (infoEditing)

import Html as H
import Html.Attributes as A
import Models.User exposing (User)
import Translation exposing (T)


infoEditing : T -> User -> H.Html msg
infoEditing t user =
    H.div
        [ A.class "profile__editing--membership container" ]
        [ H.div
            [ A.class "row" ]
            [ dataBoxEditing t user
            , dataInfo t
            ]
        ]


dataBoxEditing : T -> User -> H.Html msg
dataBoxEditing t user =
    case user.extra of
        Just extra ->
            H.div
                [ A.class "col-md-6 profile__editing--membership--databox" ]
                [ H.h3 [ A.class "profile__editing--membership--databox--heading" ] [ H.text <| t "profile.membershipRegisterInfo.heading" ]
                , registerInfo t extra
                ]

        Nothing ->
            H.div
                [ A.class "user-page__membership-info" ]
                [ H.h3 [ A.class "user-page__membership-info-heading" ] [ H.text <| t "profile.membershipRegisterInfo.missingData" ]
                ]


registerInfo : T -> Models.User.Extra -> H.Html msg
registerInfo t extra =
    let
        row titleKey value =
            H.tr []
                [ H.td [] [ H.text <| t ("profile.membershipRegisterInfo." ++ titleKey) ]
                , H.td [] [ H.text value ]
                ]
    in
    H.table
        [ A.class "user-page__membership-info-definitions" ]
        [ row "nickName" extra.nick_name
        , row "firstName" extra.first_name
        , row "lastName" extra.last_name
        , row "positions" (String.join ", " extra.positions)
        , row "domains" (String.join ", " extra.domains)
        , row "email" extra.email
        , row "phone" extra.phone
        , row "location" extra.geoArea
        ]


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
