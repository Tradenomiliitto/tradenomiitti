module Tests exposing (..)

import Test exposing (..)
import Expect
import Fuzz exposing (list, int, tuple, string)
import ListUsers exposing (chunk3)


all : Test
all =
    describe "Chunking"
        [ describe "Fuzz test algorithm"
            [ fuzz (list int) "Elements stay in same order" <|
                \aList ->
                    List.concat (chunk3 aList) |> Expect.equal aList
            ]
        ]
