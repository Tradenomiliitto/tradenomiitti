module Models.User exposing (..)

import Date
import Json.Decode as Json
import Json.Decode.Extra exposing (date)
import Json.Decode.Pipeline as P
import Json.Encode as JS
import Skill

-- data in Extra comes from the api
type alias Extra =
  { first_name : String
  , nick_name : String
  , last_name : String
  , domains : List String
  , positions : List String
  , email : String
  , phone : String
  , geoArea : String
  }

type alias PictureEditing =
  { pictureFileName : String
  , x : Float
  , y : Float
  , width : Float
  , height : Float
  }

type alias Settings =
  { emails_for_answers : Bool
  , email_address : String
  , emails_for_businesscards : Bool
  , emails_for_new_ads : Bool
  }

type alias Contact =
  { user : User
  , businessCard : BusinessCard
  , introText : String
  , createdAt : Date.Date
  }

type alias User =
  { id : Int
  , name : String
  , description : String
  , title : String
  , domains : List Skill.Model
  , positions : List Skill.Model
  , skills : List String
  , profileCreated : Bool
  , location : String
  , croppedPictureFileName : Maybe String -- this is for every logged in user
  , pictureEditingDetails : Maybe PictureEditing
  , extra : Maybe Extra
  , businessCard : Maybe BusinessCard
  , contacted : Bool
  , education : List Education
  }

type alias Education =
  { institute : String
  , degree : Maybe String
  , major : Maybe String
  , specialization : Maybe String
  }

type alias BusinessCard =
  { name : String
  , title : String
  , location : String
  , phone : String
  , email : String
  , linkedin : String
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
    |> P.required "special_skills" (Json.list Json.string)
    |> P.required "profile_creation_consented" Json.bool
    |> P.required "location" Json.string
    |> P.required "cropped_picture" (Json.string |> Json.map
                                     (\str -> if String.length str == 0 then Nothing else Just str))
    |> P.optional "picture_editing" (Json.map Just pictureEditingDecoder) Nothing
    |> P.optional "extra" (Json.map Just userExtraDecoder) Nothing
    |> P.optional "business_card" (Json.map Just businessCardDecoder) Nothing
    |> P.optional "contacted" Json.bool False
    |> P.hardcoded [ Education "first uni" (Just "Tradenomi") Nothing (Just "awesomeness specialization"), Education "second uni" Nothing (Just "amazing major") Nothing ]

encode : User -> JS.Value
encode user =
  JS.object <|
    [ ("name", JS.string user.name)
    , ("description", JS.string user.description)
    , ("title", JS.string user.title)
    , ("domains", JS.list (List.map Skill.encode user.domains) )
    , ("positions", JS.list (List.map Skill.encode user.positions) )
    , ("location", JS.string user.location)
    , ("cropped_picture", JS.string (user.croppedPictureFileName |> Maybe.withDefault ""))
    , ("special_skills", JS.list (List.map JS.string user.skills))
    ] ++ (
         user.pictureEditingDetails
           |> Maybe.map (\details ->
                          [ ("picture_editing", pictureEditingEncode details) ]
                       )
           |> Maybe.withDefault []
        )
      ++ case user.businessCard of
        Nothing -> []
        Just businessCard -> [("business_card", businessCardEncode businessCard)]

settingsEncode : Settings -> JS.Value
settingsEncode settings =
  JS.object
    [ ("emails_for_answers", JS.bool settings.emails_for_answers)
    , ("email_address", JS.string settings.email_address)
    , ("emails_for_businesscards", JS.bool settings.emails_for_businesscards)
    , ("emails_for_new_ads", JS.bool settings.emails_for_new_ads)
    ]

businessCardEncode : BusinessCard -> JS.Value
businessCardEncode businessCard =
  JS.object
    [ ("name", JS.string businessCard.name)
    , ("title", JS.string businessCard.title)
    , ("location", JS.string businessCard.location)
    , ("phone", JS.string businessCard.phone)
    , ("email", JS.string businessCard.email)
    , ("linkedin", JS.string businessCard.linkedin)
    ]

pictureEditingEncode : PictureEditing -> JS.Value
pictureEditingEncode details =
  JS.object
    [ ("file_name", JS.string details.pictureFileName)
    , ("x", JS.float details.x)
    , ("y", JS.float details.y)
    , ("width", JS.float details.width)
    , ("height", JS.float details.height)
    ]

userExtraDecoder : Json.Decoder Extra
userExtraDecoder =
  P.decode Extra
    |> P.required "first_name" Json.string
    |> P.required "nick_name" Json.string
    |> P.required "last_name" Json.string
    |> P.required "domains" (Json.list Json.string)
    |> P.required "positions" (Json.list Json.string)
    |> P.required "email" Json.string
    |> P.required "phone" Json.string
    |> P.required "geo_area" Json.string

pictureEditingDecoder : Json.Decoder PictureEditing
pictureEditingDecoder =
  P.decode PictureEditing
    |> P.required "file_name" Json.string
    |> P.required "x" Json.float
    |> P.required "y" Json.float
    |> P.required "width" Json.float
    |> P.required "height" Json.float


settingsDecoder : Json.Decoder Settings
settingsDecoder =
  P.decode Settings
    |> P.required "emails_for_answers" Json.bool
    |> P.required "email_address" Json.string
    |> P.required "emails_for_businesscards" Json.bool
    |> P.required "emails_for_new_ads" Json.bool

contactDecoder : Json.Decoder Contact
contactDecoder =
  P.decode Contact
    |> P.required "user" userDecoder
    |> P.required "business_card" businessCardDecoder
    |> P.required "intro_text" Json.string
    |> P.required "created_at" date

businessCardDecoder : Json.Decoder BusinessCard
businessCardDecoder =
  P.decode BusinessCard
    |> P.required "name" Json.string
    |> P.required "title" Json.string
    |> P.required "location" Json.string
    |> P.required "phone" Json.string
    |> P.required "email" Json.string
    |> P.required "linkedin" Json.string
