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
            t "workStatus.working"

        OnLeave ->
            t "workStatus.on_leave"


toApiString : WorkStatus -> String
toApiString workStatus =
    case workStatus of
        Working ->
            "working"

        OnLeave ->
            "on_leave"


fromString : T -> String -> Maybe WorkStatus
fromString t str =
    if str == t "workStatus.working" then
        Just Working
    else if str == t "workStatus.on_leave" then
        Just OnLeave
    else
        Nothing


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
