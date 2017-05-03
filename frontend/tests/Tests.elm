module Tests exposing (..)

import Test exposing (..)
import Expect
import Fuzz exposing (list, int, tuple, string)
import Common exposing (chunk2, chunk3)


all : Test
all =
    describe "Chunking"
        [ describe "Fuzz test algorithm"
            [ fuzz (list int) "Elements stay in same order for chunk3" <|
                \aList ->
                    List.concat (chunk3 aList) |> Expect.equal aList
            , fuzz (list int) "Elements stay in same order for chunk2" <|
                \aList ->
                    List.concat (chunk2 aList) |> Expect.equal aList
            ]
        ]
