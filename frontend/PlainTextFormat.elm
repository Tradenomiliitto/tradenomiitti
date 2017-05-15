module PlainTextFormat exposing (view)

import Html as H

view : String -> List (H.Html msg)
view str =
  let
    paragraphs =
      str
        |> String.split "\n\n"

    lines paragraph =
      paragraph
        |> String.split "\n"
        |> List.map H.text
        |> List.intersperse (H.br [] [])
  in
    List.map (\p -> H.p [] (lines p)) paragraphs
