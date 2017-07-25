module FamilyStatus exposing (..)

import Json.Decode exposing (..)
import Translation exposing (T)
import Util


type FamilyStatus
    = Pregnant
    | Baby
    | Toddler
    | Schoolkid
    | Teenager
    | GrownUpChildren


toString : T -> List FamilyStatus -> String
toString t familyStatusList =
    familyStatusList
        |> List.map (translate t)
        |> String.join ", "
        |> Util.capitalize


translate : T -> FamilyStatus -> String
translate t familyStatus =
    case familyStatus of
        Pregnant ->
            "odottaa"

        Baby ->
            "vauva"

        Toddler ->
            "taapero"

        Schoolkid ->
            "kouluikäinen"

        Teenager ->
            "teini-ikäinen"

        GrownUpChildren ->
            "aikuinen lapsi"


decoder : Decoder FamilyStatus
decoder =
    let
        toStatus str =
            case str of
                "pregnant" ->
                    succeed Pregnant

                "baby" ->
                    succeed Baby

                "toddler" ->
                    succeed Toddler

                "schoolkid" ->
                    succeed Schoolkid

                "teenager" ->
                    succeed Teenager

                "grown_up_children" ->
                    succeed GrownUpChildren

                other ->
                    fail <| "Perhetilanteelle '" ++ other ++ "' ei löytynyt vastaavuutta"
    in
    string
        |> andThen toStatus


listDecoder : Decoder (List FamilyStatus)
listDecoder =
    list decoder
