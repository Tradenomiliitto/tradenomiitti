module QueryString.Extra exposing (optional)

import QueryString exposing (..)

optional : String -> Maybe String -> QueryString -> QueryString
optional k maybeValue qs =
  maybeValue
    |> Maybe.map (\v -> add k v qs)
    |> Maybe.withDefault qs

