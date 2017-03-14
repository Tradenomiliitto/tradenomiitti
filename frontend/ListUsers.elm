module ListUsers exposing (..)

import Common
import Html as H
import Html.Attributes as A
import Http
import Json.Decode as Json
import Models.User exposing (User)
import State.ListUsers exposing (..)

type Msg
  = UpdateUsers (Result Http.Error (List User))

getUsers : Cmd Msg
getUsers =
  Http.get "/api/profiilit" (Json.list Models.User.userDecoder)
    |> Http.send UpdateUsers


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    UpdateUsers (Ok users) ->
      { model | users = users } ! []
    UpdateUsers (Err _) ->
      model ! [] -- TODO error handling

view : Model -> H.Html msg
view model =
  H.div
    []
    [ H.div
      [ A.class "container" ]
      [ H.div
        [ A.class "row" ]
        [ H.div
          [ A.class "col-sm-12" ]
          [ H.h3
            [ A.class "list-users__header" ]
            [ H.text "Selaa tradenomeja" ]
          ]
        ]
      ]
    , H.div
      [ A.class "list-users__list-background"]
      [ H.div
        [ A.class "container" ]
        (List.map viewUser model.users)
      ]
    ]

viewUser : User -> H.Html msg
viewUser user =
  H.div
    [ A.class "user-card col-xs-12 col-sm-6 col-md-3"
    ]
    [ Common.authorInfo user
    ]
