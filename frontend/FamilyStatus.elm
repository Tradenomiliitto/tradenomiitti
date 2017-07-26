module FamilyStatus exposing (..)

import Date
import Date.Extra as Date
import Json.Decode as Json
import Json.Decode.Pipeline as P
import Translation exposing (T)
import Util
import WorkStatus exposing (WorkStatus)


type alias FamilyStatus =
    { children : List Birthdate
    , workStatus : WorkStatus
    }


type alias Birthdate =
    { year : Int
    , month : Int
    }


type ChildAgeCategory
    = Pregnant
    | Baby
    | Toddler
    | PlayAge
    | Schoolkid
    | Teenager
    | GrownUpChildren


decoder : Json.Decoder FamilyStatus
decoder =
    let
        birthdateDecoder : Json.Decoder Birthdate
        birthdateDecoder =
            P.decode Birthdate
                |> P.required "year" Json.int
                |> P.required "month" Json.int
    in
    P.decode FamilyStatus
        |> P.required "children" (Json.list birthdateDecoder)
        |> P.required "work_status" WorkStatus.decoder


asText : T -> FamilyStatus -> String
asText t familyStatus =
    let
        currentDate =
            Date.fromParts 2017 Date.Jul 26 0 0 0 0

        workStatus =
            WorkStatus.toString t familyStatus.workStatus

        dates =
            familyStatus.children
                |> List.map
                    (\{ year, month } ->
                        String.padLeft 2 '0' (toString month) ++ "/" ++ toString year
                    )
                |> Util.humanizeStringList t

        ageCategories =
            familyStatus.children
                |> List.filterMap (toAgeCategory currentDate)
                |> ageToString t

        textWithDates =
            workStatus ++ ". Äidiksi " ++ dates ++ "."

        textWithCategories =
            workStatus ++ ". " ++ ageCategories
    in
    -- textWithCategories
    textWithDates


ageToString : T -> List ChildAgeCategory -> String
ageToString t =
    List.map (translate t)
        >> Util.humanizeStringList t
        >> Util.toSentence


translate : T -> ChildAgeCategory -> String
translate t familyStatus =
    case familyStatus of
        Pregnant ->
            "odottaa"

        Baby ->
            "vauva"

        Toddler ->
            "taapero"

        PlayAge ->
            "leikki-ikäinen"

        Schoolkid ->
            "kouluikäinen"

        Teenager ->
            "teini-ikäinen"

        GrownUpChildren ->
            "aikuinen lapsi"


toAgeCategory : Date.Date -> Birthdate -> Maybe ChildAgeCategory
toAgeCategory currentDate birthdate =
    let
        yearsToCategory years =
            if years < 0 then
                Pregnant
            else if years < 1 then
                Baby
            else if years < 3 then
                Toddler
            else if years < 7 then
                PlayAge
            else if years < 12 then
                Schoolkid
            else if years < 19 then
                Teenager
            else
                GrownUpChildren
    in
    [ birthdate.year, birthdate.month, 1 ]
        |> List.map (String.padLeft 2 '0' << toString)
        |> String.join "-"
        |> Date.fromIsoString
        |> Maybe.map
            (\date ->
                Date.diff Date.Year date currentDate
                    |> Debug.log ("diff: " ++ toString date ++ ", " ++ toString currentDate)
                    |> yearsToCategory
            )
