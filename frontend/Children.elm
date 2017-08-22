module Children exposing (..)

import Date
import Date.Extra as Date
import Json.Decode as Json
import Json.Decode.Pipeline as P
import Translation exposing (T)
import Util


type alias Children =
    List Birthdate


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


decoder : Json.Decoder Children
decoder =
    let
        birthdateDecoder : Json.Decoder Birthdate
        birthdateDecoder =
            P.decode Birthdate
                |> P.required "year" Json.int
                |> P.required "month" Json.int
    in
    Json.list birthdateDecoder


sort : Children -> Children
sort =
    List.sortBy birthdateToComparable >> List.reverse


birthdateToComparable : Birthdate -> String
birthdateToComparable { year, month } =
    toString year
        ++ "-"
        ++ String.padLeft 2 '0' (toString month)


birthdateToString : Birthdate -> String
birthdateToString { year, month } =
    String.padLeft 2 '0' (toString month)
        ++ "/"
        ++ toString year


dates : Children -> List String
dates =
    List.map birthdateToString


asText : T -> Maybe Date.Date -> Children -> String
asText t maybeCurrentDate children =
    let
        ageCategories currentDate =
            children
                |> List.filterMap (toAgeCategory currentDate)
                |> List.map (translate t)
                |> Util.humanizeStringList t
                |> Util.toSentence

        ages currentDate =
            children
                |> List.filterMap (toAge currentDate)
                |> List.map (\age -> toString age ++ "v")
                |> Util.humanizeStringList t
                |> Util.toSentence

        textWithDates =
            t "children.becameMother"
                ++ " "
                ++ Util.humanizeStringList t (dates children)
                ++ "."

        childCount =
            List.length children

        textWithAges currentDate =
            if childCount == 1 then
                t "children.child" ++ " " ++ ages currentDate
            else if childCount > 1 then
                t "children.children" ++ " " ++ ages currentDate
            else
                ""

        textWithCategories =
            ageCategories
    in
    case maybeCurrentDate of
        Just currentDate ->
            textWithAges currentDate

        Nothing ->
            textWithDates


translate : T -> ChildAgeCategory -> String
translate t children =
    case children of
        Unborn ->
            t "children.ageCategories.unborn"

        Baby ->
            t "children.ageCategories.baby"

        Toddler ->
            t "children.ageCategories.toddler"

        PlayAge ->
            t "children.ageCategories.playAge"

        Schoolkid ->
            t "children.ageCategories.schoolkid"

        Teenager ->
            t "children.ageCategories.teenager"

        GrownUpChildren ->
            t "children.ageCategories.grownUpChildren"


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
