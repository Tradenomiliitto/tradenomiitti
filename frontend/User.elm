module User exposing (..)

import Http
import Json.Decode exposing (Decoder, string, list, bool, int)
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

type alias Model =
  { user : Maybe User
  , spinning : Bool
  }

init : Model
init =
  { user = Nothing
  , spinning = False
  }

userDecoder : Decoder User
userDecoder =
  P.decode User
    |> P.required "id" int
    |> P.required "name" string
    |> P.required "description" string
    |> P.required "title" string
    |> P.required "domains" (list Skill.decoder)
    |> P.required "positions" (list Skill.decoder)
    |> P.required "profile_creation_consented" bool
    |> P.optional "extra" (Json.Decode.map Just userExtraDecoder) Nothing

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

userExtraDecoder : Decoder Extra
userExtraDecoder =
  P.decode Extra
    |> P.required "first_name" string
    |> P.required "nick_name" string
    |> P.required "domains" (list string)
    |> P.required "positions" (list string)

-- UPDATE

type Msg
  = UpdateUser (Result Http.Error User)
  | GetUser Int
  | NoOp

update : Msg -> Model -> ( Model, Cmd Msg)
update msg model =
  case msg of
    UpdateUser (Ok updatedUser) ->
      { model | user = Just updatedUser, spinning = False } ! []
    -- TODO: show error
    UpdateUser (Err _) ->
      { model | user = Nothing, spinning = False } ! []

    GetUser userId ->
      { model | spinning = True } ! [ getUser userId ]

    NoOp ->
      model ! []

getUser : Int -> Cmd Msg
getUser userId =
  let
    url = "/api/tradenomit/" ++ (toString userId)
    request = Http.get url userDecoder
  in
    Http.send UpdateUser request


-- VIEW

view whatever = Debug.crash "Not implemented"
