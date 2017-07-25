module WorkStatus exposing (..)

import Json.Decode exposing (..)
import Translation exposing (T)


type WorkStatus
    = Working
    | OnLeave


toString : T -> WorkStatus -> String
toString t workStatus =
    case workStatus of
        Working ->
            "Työelämässä"

        OnLeave ->
            "Vapaalla"


decoder : Decoder WorkStatus
decoder =
    let
        toStatus str =
            case str of
                "on_leave" ->
                    succeed OnLeave

                "working" ->
                    succeed Working

                other ->
                    fail <| "Työtilanteelle '" ++ other ++ "' ei löytynyt vastaavuutta"
    in
    string
        |> andThen toStatus
