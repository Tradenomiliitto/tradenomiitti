module Tests exposing (..)

import Test exposing (..)
import Regex
import Expect
import Fuzz exposing (list, int, tuple, string)
import Common exposing (chunk2, chunk3)
import Util exposing (truncateContent)


all : Test
all =
    describe "All"
        [ describe "Fuzz test chunking algorithm"
            [ fuzz (list int) "Elements stay in same order for chunk3" <|
                \aList ->
                    List.concat (chunk3 aList) |> Expect.equal aList
            , fuzz (list int) "Elements stay in same order for chunk2" <|
                \aList ->
                    List.concat (chunk2 aList) |> Expect.equal aList
            ]
        , describe "Fuzz test truncation algorithm"
          [ fuzz (tuple (string, int)) "original starts with truncation minus ellipsis and whitespace" <|
              \ (str, numChars) ->
              let
                strippedWhiteSpace = str
                  |> normalize
                truncated = truncateContent str numChars
                  |> normalize
              in
                String.startsWith truncated strippedWhiteSpace
                  |> Expect.true ("'" ++ strippedWhiteSpace ++ "' should start with '" ++ truncated ++ "'")
          , test "known string" <|
            \ () ->
              let
                knownString = "word word LONGLONGLONGWORD short" |> normalize
                truncated =
                  truncateContent knownString 17
                    |> normalize
              in
                String.startsWith truncated knownString
                  |> Expect.true ("'" ++ knownString ++ "' should start with '" ++ truncated ++ "'")
          ]
        ]

normalize : String -> String
normalize string =
  string
    |> Regex.replace Regex.All (Regex.regex "…") (always "")
    |> Regex.replace Regex.All (Regex.regex "\\s+") (always " ")
    |> Regex.replace Regex.All (Regex.regex "^\\s+") (always "")
