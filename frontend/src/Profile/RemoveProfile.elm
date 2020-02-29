module Profile.RemoveProfile exposing (view)

import Html as H
import Html.Attributes as A
import Html.Events as E
import Profile.Main exposing (Msg(..), Position(..))
import Removal
import State.Profile exposing (Model)
import Translation exposing (T)
import Util exposing (UpdateMessage(..), ViewMessage(..), qsOptional)


view : T -> Model -> H.Html (ViewMessage Msg)
view t model =
    H.div
        [ A.class "remove-profile last-row" ]
        [ H.div [ A.class "container" ]
            [ H.div [ A.class "row" ]
                [ H.div [ A.class "col-xs-12" ]
                    [ H.h3 [ A.class "remove-profile-header" ]
                        [ H.text <| t "profile.removeProfile.heading" ]
                    , H.p [] [ H.text <| t "profile.removeProfile.description" ]
                    , H.p [ A.class "remove-profile__button" ]
                        ([ Util.localViewMap ProfileRemovalMessage <|
                            H.button
                                [ A.class "btn btn-primary"
                                , E.onClick <| (Util.LocalViewMessage <| Removal.InitiateRemove 0 0)
                                ]
                                [ H.text <| t "profile.removeProfile.button"
                                ]
                         ]
                            ++ (List.map (Util.localViewMap ProfileRemovalMessage) <| Removal.view t Nothing 0 { id = 0, createdBy = { id = 0 } } model.profileRemoval)
                        )
                    ]
                ]
            ]
        ]
