module StaticContent exposing (..)

import Http
import State.StaticContent exposing (..)
import Util exposing (UpdateMessage(..))


type Msg
    = GetInfo StaticContent


getInfo : Cmd (UpdateMessage Msg)
getInfo =
    Http.get "/static/info.json" decoder
        |> Util.errorHandlingSend GetInfo


initTasks : Cmd (UpdateMessage Msg)
initTasks =
    getInfo


update : Msg -> Model -> ( Model, Cmd msg )
update msg model =
    case msg of
        GetInfo info ->
            { model | info = info } ! []
