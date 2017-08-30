module Util exposing (..)

import Char
import Date
import Html as H
import Http
import Json.Encode as JS
import Nav exposing (Route)
import Task
import Translation exposing (T)


type ViewMessage msg
    = Link Route
    | LocalViewMessage msg


type UpdateMessage msg
    = LocalUpdateMessage msg
    | ApiError Http.Error
    | Reroute Route
    | RefreshMe


makeCmd : msg -> Cmd msg
makeCmd msg =
    Task.succeed msg
        |> Task.perform identity


localMap : (msg1 -> msg2) -> Cmd (UpdateMessage msg1) -> Cmd (UpdateMessage msg2)
localMap msgMapper cmd =
    let
        mapper appMsg =
            case appMsg of
                LocalUpdateMessage msg ->
                    LocalUpdateMessage <| msgMapper msg

                ApiError err ->
                    ApiError err

                Reroute route ->
                    Reroute route

                RefreshMe ->
                    RefreshMe
    in
    Cmd.map mapper cmd


localViewMap : (msg1 -> msg2) -> H.Html (ViewMessage msg1) -> H.Html (ViewMessage msg2)
localViewMap msgMapper html =
    let
        mapper appMsg =
            case appMsg of
                LocalViewMessage msg ->
                    LocalViewMessage <| msgMapper msg

                Link route ->
                    Link route
    in
    H.map mapper html


reroute : Route -> Cmd (UpdateMessage msg)
reroute route =
    makeCmd (Reroute route)


asApiError : Http.Error -> Cmd (UpdateMessage msg)
asApiError err =
    makeCmd (ApiError err)


refreshMe : Cmd (UpdateMessage msg)
refreshMe =
    makeCmd RefreshMe


errorHandlingSend : (a -> msg) -> Http.Request a -> Cmd (UpdateMessage msg)
errorHandlingSend happyPath request =
    let
        handler result =
            case result of
                Ok happy ->
                    LocalUpdateMessage <| happyPath happy

                Err err ->
                    ApiError err
    in
    Http.send handler request


getDate : (Date.Date -> msg) -> Cmd (UpdateMessage msg)
getDate tagger =
    Task.perform (LocalUpdateMessage << tagger) Date.now


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


delete : String -> Http.Request ()
delete url =
    Http.request
        { method = "DELETE"
        , headers = []
        , url = url
        , body = Http.emptyBody
        , expect = Http.expectStringResponse (\_ -> Ok ())
        , timeout = Nothing
        , withCredentials = False
        }



-- truncates content so that the result includes at most numChars characters, taking full words. "…" is added if the content is truncated


truncateContent : String -> Int -> String
truncateContent content numChars =
    if String.length content < numChars then
        content
    else
        let
            ( truncated, _ ) =
                List.foldl (takeNChars numChars) ( "", True ) (String.words content)
        in
        -- drop extra whitespace created by takeNChars and add three dots
        String.dropRight 1 truncated ++ "…"



-- takes first x words where sum of the characters is less than n
-- canAddMore is needed so we don't skip long words and take a short word
-- after some dropped long words. When we can't add something, we don't
-- add anymore


takeNChars : Int -> String -> ( String, Bool ) -> ( String, Bool )
takeNChars n word ( accumulator, canAddMore ) =
    let
        totalLength =
            String.length accumulator + String.length word
    in
    if totalLength < n && canAddMore then
        ( accumulator ++ word ++ " ", canAddMore )
    else
        ( accumulator, False )


toSentence : String -> String
toSentence string =
    case String.uncons string of
        Just ( first, rest ) ->
            String.cons (Char.toUpper first) rest ++ "."

        Nothing ->
            ""


humanizeStringList : T -> List String -> String
humanizeStringList t stringList =
    let
        lastIndex =
            List.length stringList - 1
    in
    stringList
        |> List.indexedMap
            (\index a ->
                if index == lastIndex then
                    a
                else if index == lastIndex - 1 then
                    a ++ " " ++ t "common.and" ++ " "
                else
                    a ++ ", "
            )
        |> String.join ""
