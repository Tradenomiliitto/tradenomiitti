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

view : Model -> Html Msg
view model =
  if not model.spinning
  then
    model.user
      |> Maybe.map viewUser
      |> Maybe.withDefault (H.div [] [])
  else
    H.div [] [ H.text "spinning"]


viewUser : User -> Html Msg
viewUser user =
  H.div
    []
    [ H.h1 [] [ H.text "Profiili" ]
    , H.p [] [ H.text "Alla olevat tiedot on täytetty jäsentiedoistasi" ]
    , viewProfileForm user
    ]

viewProfileForm : User -> Html Msg
viewProfileForm user =
  H.form
    []
    [ H.div
        [ A.class "form-group"]
        [ H.label [] [ H.text "Millä nimellä meidän tulisi kutsua sinua?" ]
        , H.input
          [ A.value user.name
          , A.class "form-control"
          , E.onInput <| always NoOp
          ] []
        ]
    , H.div
      [ A.class "form-group" ]
      [ H.label [] [ H.text "Kuvaile itseäsi" ]
      , H.input
        [ A.value user.description
        , A.class "form-control"
        , E.onInput <| always NoOp
        ] []
      ]
    , H.div
      [ A.class "form-group" ]
      ([ H.label [] [ H.text "Tehtävät, joista sinulla on kokemusta" ]] ++
         viewPositions user.positions)
    ]

viewPositions : List String -> List (Html Msg)
viewPositions positions =
  List.map (\position -> H.input
              [ A.value position
              , A.class "form-control"
              , E.onInput <| always NoOp
              ] []) positions
