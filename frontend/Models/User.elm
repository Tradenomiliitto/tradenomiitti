module Models.User exposing (..)

import Json.Decode as Json
import Json.Decode.Pipeline as P
import Json.Encode as JS
import Skill

-- data in Extra comes from the api
type alias Extra =
  { first_name : String
  , nick_name : String
  , domains : List String
  , positions : List String
  }

type alias PictureEditing =
  { pictureUrl : String
  , x : Int
  , y : Int
  , width : Int
  , height : Int
  }

type alias Settings =
  { emails_for_answers : Bool
  , email_address : String
  }

type alias User =
  { id : Int
  , name : String
  , description : String
  , primaryPosition : String
  , domains : List Skill.Model
  , positions : List Skill.Model
  , profileCreated : Bool
  , location : String
  , croppedPictureUrl : Maybe String -- this is for every logged in user
  , pictureEditingDetails : Maybe PictureEditing
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
    |> P.required "location" Json.string
    |> P.required "croppedPicture" (Json.string |> Json.map
                                     (\str -> if String.length str == 0 then Nothing else Just str))
    |> P.optional "picture_editing" (Json.map Just pictureEditingDecoder) Nothing
    |> P.optional "extra" (Json.map Just userExtraDecoder) Nothing

encode : User -> JS.Value
encode user =
  JS.object <|
    [ ("name", JS.string user.name)
    , ("description", JS.string user.description)
    , ("title", JS.string user.primaryPosition)
    , ("domains", JS.list (List.map Skill.encode user.domains) )
    , ("positions", JS.list (List.map Skill.encode user.positions) )
    , ("location", JS.string user.location)
    ]

settingsEncode : Settings -> JS.Value
settingsEncode settings =
  JS.object
    [ ("emails_for_answers", JS.bool settings.emails_for_answers)
    , ("email_address", JS.string settings.email_address)
    ]

userExtraDecoder : Json.Decoder Extra
userExtraDecoder =
  P.decode Extra
    |> P.required "first_name" Json.string
    |> P.required "nick_name" Json.string
    |> P.required "domains" (Json.list Json.string)
    |> P.required "positions" (Json.list Json.string)

pictureEditingDecoder : Json.Decoder PictureEditing
pictureEditingDecoder =
  P.decode PictureEditing
    |> P.required "url" Json.string
    |> P.required "x" Json.int
    |> P.required "y" Json.int
    |> P.required "width" Json.int
    |> P.required "height" Json.int


settingsDecoder : Json.Decoder Settings
settingsDecoder =
  P.decode Settings
    |> P.required "emails_for_answers" Json.bool
    |> P.required "email_address" Json.string
