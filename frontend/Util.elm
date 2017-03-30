module Util exposing (..)

import Http
import Json.Encode as JS
import Nav exposing (Route)


type AppMessage msg  = Link Route | LocalMessage msg


put : String -> JS.Value -> Http.Request ()
put url body =
  Http.request
    { method = "PUT"
    , headers = []
    , url = url
    , body = Http.jsonBody body
    , expect = Http.expectStringResponse (\_ -> Ok ())
    , timeout = Nothing
    , withCredentials = False
    }



-- truncates content so that the result includes at most numChars characters, taking full words. "…" is added if the content is truncated
truncateContent : String -> Int -> String
truncateContent content numChars =
  if (String.length content) < numChars
    then content
    else
      let
        truncated = List.foldl (takeNChars numChars) "" (String.words content)
      in
        -- drop extra whitespace created by takeNChars and add three dots
        (String.dropRight 1 truncated) ++ "…"

-- takes first x words where sum of the characters is less than n
takeNChars : Int -> String -> String -> String
takeNChars n word accumulator =
  let
    totalLength = (String.length accumulator) + (String.length word)
  in
    if totalLength < n
      then accumulator ++ word ++ " "
      else accumulator
