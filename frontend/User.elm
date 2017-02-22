module User exposing (..)

import Html as H exposing (Html)
import Html.Attributes as A
import Html.Events as E
import Http
import Json.Decode exposing (Decoder, string, list)
import Json.Decode.Pipeline exposing (decode, required, optional)

type alias User =
  { name : String
  , description : String
  , positions : List String
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
  decode User
    |> required "first_name" string
    |> required "description" string
    |> required "positions" (list string)

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
