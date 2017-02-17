module Profile exposing (..)

import Http
import User

getMe : ((Result Http.Error User.User) -> msg) -> Cmd msg
getMe toMsg =
  Http.get "/api/me" User.userDecoder
    |> Http.send toMsg
