module Tests exposing (..)

import Common exposing (chunk2, chunk3)
import Expect
import Fuzz exposing (list, int, tuple, string)
import Html as H
import PlainTextFormat
import Regex
import Test exposing (..)
import Test.Html.Query as Query
import Test.Html.Selector exposing (tag)
import Util exposing (truncateContent)


all : Test
all =
    describe "All"
      [ chunkingAlgorithm
      , truncationAlgorithm
      , urlGuessing
      ]


urlCases : List String
urlCases =
    [ "Tämä on linkki https://example.com"
    , "ja toinen linkki ilman http-alkua www.example.com"
    , "ja vielä yksi ilman www:tä, mutta kauttaviivalla example.com/sisältö"
    , "ja vielä taas, jossa sulkeva sulje, pilkku, tai piste ei kuulu linkkiin http://example.com/mitätahansa."
    ]

urlGuessing : Test
urlGuessing =
  describe "Url guessing algorithm" <|
    List.map (\str -> test "has a single link" <|
                \ () ->
                H.div [] (PlainTextFormat.view str)
                |> Query.fromHtml
                |> Query.findAll [ tag "a" ]
                |> Query.count (Expect.equal 1)
             ) urlCases

chunkingAlgorithm : Test
chunkingAlgorithm =
  describe "Fuzz test chunking algorithm"
    [ fuzz (list int) "Elements stay in same order for chunk3" <|
        \aList ->
            List.concat (chunk3 aList) |> Expect.equal aList
    , fuzz (list int) "Elements stay in same order for chunk2" <|
        \aList ->
            List.concat (chunk2 aList) |> Expect.equal aList
    ]

truncationAlgorithm : Test
truncationAlgorithm =
  describe "Fuzz test truncation algorithm"
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

normalize : String -> String
normalize string =
  string
    |> Regex.replace Regex.All (Regex.regex "…") (always "")
    |> Regex.replace Regex.All (Regex.regex "\\s+") (always " ")
    |> Regex.replace Regex.All (Regex.regex "^\\s+") (always "")
