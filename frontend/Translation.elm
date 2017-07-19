module Translation exposing (..)

import Dict exposing (Dict)
import List.Extra as List


{-| Type signature for the commonplace `t` function
-}
type alias T =
    String -> String


type alias Translations =
    Dict String String


type alias HasTranslations a =
    { a | translations : Translations }


fromList : List ( String, String ) -> Translations
fromList =
    Dict.fromList


{-| Conveniently find translation for key, falling back to an error explanation.
-}
get : Translations -> String -> String
get dict key =
    let
        toPlaceholder : String -> String
        toPlaceholder value =
            "Translation missing: \"" ++ value ++ "\""
    in
    dict
        |> Dict.get key
        |> Maybe.withDefault (toPlaceholder key)


{-| Takes a "template string" with `{.}` denominators, and a list of replacements to go into those places.
-}
getWith : Translations -> String -> List String -> String
getWith translations key replacements =
    get translations key
        |> String.split "{.}"
        |> flip List.interweave replacements
        |> String.join ""
