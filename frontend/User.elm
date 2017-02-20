module User exposing (..)

import Html exposing (Html, div, text, input)
import Html.Attributes as A
import Http
import Json.Decode exposing (Decoder, string, list)
import Json.Decode.Pipeline exposing (decode, required, optional)

type alias User =
  { name : String
  , description : String
  , positions : List String
  }

userDecoder : Decoder User
userDecoder =
  decode User
    |> required "first_name" string
    |> required "description" string
    |> required "positions" (list string)

-- UPDATE

type Msg = UpdateUser (Result Http.Error User)

update : Msg -> Maybe User -> ( Maybe User, Cmd Msg)
update msg user =
  case msg of
    UpdateUser (Ok updatedUser) ->
      Just updatedUser ! []
    -- TODO: show error instead of spinning in case of user not found
    UpdateUser (Err _) ->
      Nothing ! []

getUser : Int -> Cmd Msg
getUser userId =
  let
    url = "/api/user/" ++ (toString userId)
    request = Http.get url userDecoder
  in
    Http.send UpdateUser request


-- VIEW

view : Maybe User -> Html Msg
view userMaybe =
  userMaybe
    |> Maybe.map viewUser
    |> Maybe.withDefault (div [] [text "spinning"])


viewUser : User -> Html Msg
viewUser user =
  div [] <|
  [ div
      []
      [ input [ A.value user.name ] [] ]
  , div
      []
      [ text user.description ]
  ] ++ (viewPositions user.positions)

viewPositions : List String -> List (Html Msg)
viewPositions positions =
  List.map (\position -> input [ A.value position ] []) positions
