module Translation exposing (HasTranslations, Translations, fromList, get)

import Dict exposing (Dict)


type alias Translations =
    Dict String String


type alias HasTranslations a =
    { a | translations : Translations }


fromList : List ( String, String ) -> Translations
fromList =
    Dict.fromList


get : Translations -> String -> String
get dict key =
    dict
        |> Dict.get key
        |> Maybe.withDefault (toPlaceholder key)


toPlaceholder : String -> String
toPlaceholder value =
    "Cannot find content for \"" ++ value ++ "\"."
