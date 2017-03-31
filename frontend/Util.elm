module Util exposing (..)

import Http
import Json.Encode as JS
import Nav exposing (Route)
import Task


type ViewMessage msg
  = Link Route
  | LocalViewMessage msg

type UpdateMessage msg
  = LocalUpdateMessage msg
  | ApiError Http.Error
  | Reroute Route


makeCmd : msg -> Cmd msg
makeCmd msg =
  Task.succeed msg
    |> Task.perform identity

localMap : (msg1 -> msg2) -> Cmd (UpdateMessage msg1) -> Cmd (UpdateMessage msg2)
localMap msgMapper cmd =
  let
    mapper appMsg =
      case appMsg of
        LocalUpdateMessage msg -> LocalUpdateMessage <| msgMapper msg
        ApiError err -> ApiError err
        Reroute route -> Reroute route
  in
    Cmd.map mapper cmd

reroute : Route -> Cmd (UpdateMessage msg)
reroute route =
  makeCmd (Reroute route)


asApiError : Http.Error -> Cmd (UpdateMessage msg)
asApiError err =
  makeCmd (ApiError err)


errorHandlingSend : (a -> msg) -> Http.Request a -> Cmd (UpdateMessage msg)
errorHandlingSend happyPath request =
  let
    handler result =
      case result of
        Ok happy -> LocalUpdateMessage <| happyPath happy
        Err err -> ApiError err
  in
    Http.send handler request

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
