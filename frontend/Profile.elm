module Profile exposing (..)

import Html as H
import Http
import User

getMe : ((Result Http.Error User.User) -> msg) -> Cmd msg
getMe toMsg =
  Http.get "/api/me" User.userDecoder
    |> Http.send toMsg


view : User.Model -> H.Html msg -> (User.Msg -> msg) -> H.Html msg
view userModel loginHandler toMsg =
  H.div
    []
    [ loginHandler
    , H.map toMsg <| User.view userModel
    ]
