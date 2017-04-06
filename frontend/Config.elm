module Config exposing (..)

import Http
import Json.Decode as Json
import State.Config exposing (..)
import Util exposing (UpdateMessage(..))

type Msg
  = GetDomainOptions (List String)
  | GetPositionOptions (List String)

getDomainOptions : Cmd (UpdateMessage Msg)
getDomainOptions =
  Http.get "/api/toimialat" (Json.list Json.string)
    |> Util.errorHandlingSend GetDomainOptions

getPositionOptions : Cmd (UpdateMessage Msg)
getPositionOptions =
  Http.get "/api/tehtavaluokat" (Json.list Json.string)
    |> Util.errorHandlingSend GetPositionOptions


initTasks : Cmd (UpdateMessage Msg)
initTasks =
  Cmd.batch [ getPositionOptions, getDomainOptions ]


update : Msg -> Model -> (Model, Cmd msg)
update msg model =
  case msg of
    GetPositionOptions list ->
      { model | positionOptions = list } ! []

    GetDomainOptions list ->
      { model | domainOptions = list } ! []
