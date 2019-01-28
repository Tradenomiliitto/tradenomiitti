module Tests exposing (chunkingAlgorithm, normalize, testUrlGuess, truncationAlgorithm, urlGuessing)

import Common exposing (chunk2, chunk3)
import Expect
import Fuzz exposing (int, list, string, tuple)
import Html as H
import PlainTextFormat
import Regex
import Test exposing (..)
import Test.Html.Query as Query
import Test.Html.Selector exposing (attribute, tag)
import Util exposing (truncateContent)


urlGuessing : Test
urlGuessing =
    describe "Url guessing algorithm" <|
        [ testUrlGuess
            { testString = "Tämä on linkki https://example.com"
            , expectedUrl = "https://example.com"
            }
        , testUrlGuess
            { testString = "ja toinen linkki ilman http-alkua www.example.com"
            , expectedUrl = "http://www.example.com"
            }
        , testUrlGuess
            { testString = "ja vielä yksi ilman www:tä, mutta kauttaviivalla example.com/sisältö"
            , expectedUrl = "http://example.com/sisältö"
            }
        , testUrlGuess
            { testString = "ja vielä taas, jossa sulkeva sulje, pilkku, tai piste ei kuulu linkkiin http://example.com/mitätahansa."
            , expectedUrl = "http://example.com/mitätahansa"
            }
        , testUrlGuess
            { testString = "Myös alkava sulje pitäisi urlittaa (http://example.com)"
            , expectedUrl = "http://example.com"
            }
        , testUrlGuess
            { testString = "Jos päättyy )., sulkeva sulje ei silti ole osa urlia (http://example.com)."
            , expectedUrl = "http://example.com"
            }
        ]


testUrlGuess : { expectedUrl : String, testString : String } -> Test
testUrlGuess { expectedUrl, testString } =
    test ("has a single link: \"" ++ testString ++ "\"") <|
        \() ->
            let
                elements =
                    H.div []
                        (PlainTextFormat.view testString)
                        |> Query.fromHtml
                        |> Query.findAll [ tag "a" ]
            in
            Expect.all
                [ Query.count (Expect.equal 1)
                , Query.first >> Query.has [ attribute "href" expectedUrl ]
                ]
                elements


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
        [ fuzz (tuple ( string, int )) "original starts with truncation minus ellipsis and whitespace" <|
            \( str, numChars ) ->
                let
                    strippedWhiteSpace =
                        str
                            |> normalize

                    truncated =
                        truncateContent str numChars
                            |> normalize
                in
                String.startsWith truncated strippedWhiteSpace
                    |> Expect.true ("'" ++ strippedWhiteSpace ++ "' should start with '" ++ truncated ++ "'")
        , test "known string" <|
            \() ->
                let
                    knownString =
                        "word word LONGLONGLONGWORD short" |> normalize

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
