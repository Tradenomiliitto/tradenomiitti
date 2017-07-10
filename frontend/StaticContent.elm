module StaticContent exposing (..)

import Http
import State.StaticContent exposing (..)
import Util exposing (UpdateMessage(..))


type Msg
    = GetInfo StaticContent
    | GetTerms StaticContent
    | GetRegisterDescription StaticContent


getInfo : Cmd (UpdateMessage Msg)
getInfo =
    Http.get "/static/info.json" decoder
        |> Util.errorHandlingSend GetInfo


getTerms : Cmd (UpdateMessage Msg)
getTerms =
    Http.get "/static/terms.json" decoder
        |> Util.errorHandlingSend GetTerms


getRegisterDescription : Cmd (UpdateMessage Msg)
getRegisterDescription =
    Http.get "/static/register-description.json" decoder
        |> Util.errorHandlingSend GetRegisterDescription


initTasks : Cmd (UpdateMessage Msg)
initTasks =
    Cmd.batch
        [ getInfo
        , getTerms
        , getRegisterDescription
        ]


update : Msg -> Model -> ( Model, Cmd msg )
update msg model =
    case msg of
        GetInfo info ->
            { model | info = info } ! []

        GetTerms terms ->
            { model | terms = terms } ! []

        GetRegisterDescription registerDescription ->
            { model | registerDescription = registerDescription } ! []
