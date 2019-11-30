module Models.Ad exposing (Ad, Answer, Answers(..), adCount, adDecoder, answerDecoder, answersDecoder)

import Date
import Json.Decode as Json
import Json.Decode.Extra exposing (datetime)
import Json.Decode.Pipeline as P
import Models.User exposing (User)
import Time


type alias Ad =
    { heading : String
    , content : String
    , answers : Answers
    , domain : Maybe String
    , position : Maybe String
    , location : Maybe String
    , createdBy : User
    , createdAt : Time.Posix
    , id : Int
    }


type Answers
    = AnswerCount Int
    | AnswerList (List Answer)


type alias Answer =
    { content : String
    , createdBy : User
    , createdAt : Time.Posix
    , id : Int
    }


adDecoder : Json.Decoder Ad
adDecoder =
    Json.succeed Ad
        |> P.required "heading" Json.string
        |> P.required "content" Json.string
        |> P.required "answers" answersDecoder
        |> P.optional "domain" (Json.map Just Json.string) Nothing
        |> P.optional "position" (Json.map Just Json.string) Nothing
        |> P.optional "location" (Json.map Just Json.string) Nothing
        |> P.required "created_by" Models.User.userDecoder
        |> P.required "created_at" datetime
        |> P.required "id" Json.int



--answers can be either list of answers or a number


answersDecoder : Json.Decoder Answers
answersDecoder =
    Json.oneOf
        [ Json.map AnswerCount Json.int
        , Json.map AnswerList (Json.list answerDecoder)
        ]


answerDecoder : Json.Decoder Answer
answerDecoder =
    Json.succeed Answer
        |> P.required "content" Json.string
        |> P.required "created_by" Models.User.userDecoder
        |> P.required "created_at" datetime
        |> P.required "id" Json.int


adCount : Answers -> Int
adCount answers =
    case answers of
        AnswerCount num ->
            num

        AnswerList list ->
            List.length list
