module Models.User exposing (..)

import Json.Decode as Json
import Json.Decode.Pipeline as P
import Json.Encode as JS
import Skill

type alias Extra =
  { first_name : String
  , nick_name : String
  , domains : List String
  , positions : List String
  }

type alias User =
  { id : Int
  , name : String
  , description : String
  , primaryPosition : String
  , domains : List Skill.Model
  , positions : List Skill.Model
  , profileCreated : Bool
  , extra : Maybe Extra
  }

userDecoder : Json.Decoder User
userDecoder =
  P.decode User
    |> P.required "id" Json.int
    |> P.required "name" Json.string
    |> P.required "description" Json.string
    |> P.required "title" Json.string
    |> P.required "domains" (Json.list Skill.decoder)
    |> P.required "positions" (Json.list Skill.decoder)
    |> P.required "profile_creation_consented" Json.bool
    |> P.optional "extra" (Json.map Just userExtraDecoder) Nothing

encode : User -> JS.Value
encode user =
  JS.object
    [ ("name", JS.string user.name)
    , ("description", JS.string user.description)
    , ("title", JS.string user.primaryPosition)
    , ("domains", JS.list (List.map Skill.encode user.domains) )
    , ("positions", JS.list (List.map Skill.encode user.positions) )
    , ("profile_creation_consented", JS.bool user.profileCreated)
    ]

userExtraDecoder : Json.Decoder Extra
userExtraDecoder =
  P.decode Extra
    |> P.required "first_name" Json.string
    |> P.required "nick_name" Json.string
    |> P.required "domains" (Json.list Json.string)
    |> P.required "positions" (Json.list Json.string)
