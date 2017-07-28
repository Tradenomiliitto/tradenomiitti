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
    = Unborn
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


asText : T -> Maybe Date.Date -> FamilyStatus -> String
asText t maybeCurrentDate familyStatus =
    let
        workStatus =
            WorkStatus.toString t familyStatus.workStatus

        dates =
            familyStatus.children
                |> List.map
                    (\{ year, month } ->
                        String.padLeft 2 '0' (toString month) ++ "/" ++ toString year
                    )
                |> Util.humanizeStringList t

        ageCategories currentDate =
            familyStatus.children
                |> List.filterMap (toAgeCategory currentDate)
                |> List.map (translate t)
                |> Util.humanizeStringList t
                |> Util.toSentence

        ages currentDate =
            familyStatus.children
                |> List.filterMap (toAge currentDate)
                |> List.map (\age -> toString age ++ "v")
                |> Util.humanizeStringList t
                |> Util.toSentence

        textWithDates =
            t "familyStatus.becameMother" ++ " " ++ dates ++ "."

        childCount =
            List.length familyStatus.children

        textWithAges currentDate =
            if childCount == 1 then
                t "familyStatus.child" ++ " " ++ ages currentDate
            else if childCount > 1 then
                t "familyStatus.children" ++ " " ++ ages currentDate
            else
                ""

        textWithCategories =
            ageCategories
    in
    case maybeCurrentDate of
        Just currentDate ->
            workStatus ++ ". " ++ textWithAges currentDate

        Nothing ->
            workStatus ++ ". " ++ textWithDates


translate : T -> ChildAgeCategory -> String
translate t familyStatus =
    case familyStatus of
        Unborn ->
            t "familyStatus.ageCategories.unborn"

        Baby ->
            t "familyStatus.ageCategories.baby"

        Toddler ->
            t "familyStatus.ageCategories.toddler"

        PlayAge ->
            t "familyStatus.ageCategories.playAge"

        Schoolkid ->
            t "familyStatus.ageCategories.schoolkid"

        Teenager ->
            t "familyStatus.ageCategories.teenager"

        GrownUpChildren ->
            t "familyStatus.ageCategories.grownUpChildren"


yearsToCategory : Int -> ChildAgeCategory
yearsToCategory years =
    if years < 0 then
        Unborn
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


toAge : Date.Date -> Birthdate -> Maybe Int
toAge currentDate birthdate =
    [ birthdate.year, birthdate.month, 1 ]
        |> List.map (String.padLeft 2 '0' << toString)
        |> String.join "-"
        |> Date.fromIsoString
        |> Maybe.map (\date -> Date.diff Date.Year date currentDate)


toAgeCategory : Date.Date -> Birthdate -> Maybe ChildAgeCategory
toAgeCategory currentDate birthdate =
    toAge currentDate birthdate
        |> Maybe.map yearsToCategory
