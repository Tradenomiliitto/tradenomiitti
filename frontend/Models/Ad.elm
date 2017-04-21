module Models.Ad exposing (..)

import Date
import Json.Decode as Json
import Json.Decode.Pipeline as P
import Json.Decode.Extra exposing (date)
import Models.User exposing (User)

type alias Ad =
  { heading: String
  , content: String
  , answers: Answers
  , domain : Maybe String
  , position : Maybe String
  , location : Maybe String
  , createdBy: User
  , createdAt: Date.Date
  , id: Int
  }

type Answers = AnswerCount Int | AnswerList (List Answer)

type alias Answer =
  { content: String
  , createdBy: User
  , createdAt: Date.Date
  }


adDecoder : Json.Decoder Ad
adDecoder =
  P.decode Ad
    |> P.required "heading" Json.string
    |> P.required "content" Json.string
    |> P.required "answers" answersDecoder
    |> P.optional "domain" (Json.map Just Json.string) Nothing
    |> P.optional "position" (Json.map Just Json.string) Nothing
    |> P.optional "location" (Json.map Just Json.string) Nothing
    |> P.required "created_by" Models.User.userDecoder
    |> P.required "created_at" date
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
  P.decode Answer
    |> P.required "content" Json.string
    |> P.required "created_by" Models.User.userDecoder
    |> P.required "created_at" date


adCount : Answers -> Int
adCount answers =
  case answers of
    AnswerCount num -> num
    AnswerList list -> List.length list
