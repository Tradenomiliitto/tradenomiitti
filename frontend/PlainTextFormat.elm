module PlainTextFormat exposing (view)

import Html as H
import Html.Attributes as A
import Regex


view : String -> List (H.Html msg)
view str =
    let
        paragraphs =
            str
                |> String.split "\n\n"
                |> List.map (H.p [] << lines)

        lines paragraph =
            paragraph
                |> String.split "\n"
                |> List.map withUrls
                |> List.intersperse [ H.br [] [] ]
                |> List.concatMap identity

        withUrls line =
            line
                |> String.words
                |> List.map toUrl
                |> List.intersperse [ H.text " " ]
                |> List.concatMap identity

        isUrl rawWord =
            let
                word =
                    Regex.replace Regex.All (Regex.regex "^\\(") (always "") rawWord
            in
            [ String.startsWith "http://" word
            , String.startsWith "https://" word
            , String.startsWith "www." word
            , Regex.contains (Regex.regex "\\w+\\.\\w+/\\w+") word
            ]
                |> List.any identity

        toUrl word =
            if isUrl word then
                splitSpecialChars word
            else
                [ H.text word ]

        splitSpecialChars url =
            let
                ( withoutEnd, endPart ) =
                    if Regex.contains (Regex.regex "[.,;:)]$") url then
                        ( String.dropRight 1 url, Just <| String.right 1 url )
                    else
                        ( url, Nothing )

                ( beginningPart, urlPart ) =
                    if Regex.contains (Regex.regex "^\\(") withoutEnd then
                        ( Just <| String.left 1 withoutEnd, String.dropLeft 1 withoutEnd )
                    else
                        ( Nothing, withoutEnd )

                urlWithGuessedHttp =
                    if not (String.startsWith "http" urlPart) then
                        "http://" ++ urlPart
                    else
                        urlPart
            in
            [ Maybe.map H.text beginningPart
            , Just <| H.a [ A.href urlWithGuessedHttp ] [ H.text urlPart ]
            , Maybe.map H.text endPart
            ]
                |> List.filterMap identity
    in
    paragraphs
