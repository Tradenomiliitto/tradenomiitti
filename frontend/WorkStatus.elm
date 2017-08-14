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


toApiString : WorkStatus -> String
toApiString workStatus =
    case workStatus of
        Working ->
            "working"

        OnLeave ->
            "on_leave"


fromString : String -> Maybe WorkStatus
fromString str =
    case str of
        "Työelämässä" ->
            Just Working

        "Vapaalla" ->
            Just OnLeave

        _ ->
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
