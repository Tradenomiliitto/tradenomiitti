module User exposing (..)

import Http
import Json.Decode exposing (Decoder, string, list)
import Json.Decode.Pipeline as P

type alias User =
  { name : String
  , description : String
  , positions : List String
  , primaryDomain : String
  , primaryPosition : String
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
    |> P.required "first_name" string
    |> P.required "description" string
    |> P.required "positions" (list string)
    |> P.hardcoded "Teollisuus"
    |> P.hardcoded "Kirjanpito"

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
    url = "/api/user/" ++ (toString userId)
    request = Http.get url userDecoder
  in
    Http.send UpdateUser request


-- VIEW

view whatever = Debug.crash "Not implemented"
