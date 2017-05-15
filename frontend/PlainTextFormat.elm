module PlainTextFormat exposing (view)

import Html as H

view : String -> List (H.Html msg)
view str =
  let
    paragraphs =
      str
        |> String.split "\n\n"
  in
    List.map (\p -> H.p [] [ H.text p ]) paragraphs
