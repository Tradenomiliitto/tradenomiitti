module ListUsers exposing (..)

import Common
import Html as H
import Html.Attributes as A
import Http
import Json.Decode as Json
import Link
import Models.User exposing (User)
import Nav
import State.ListUsers exposing (..)
import Util exposing (ViewMessage(..), UpdateMessage(..))

type Msg
  = UpdateUsers (List User)

getUsers : Cmd (UpdateMessage Msg)
getUsers =
  Http.get "/api/profiilit" (Json.list Models.User.userDecoder)
    |> Util.errorHandlingSend UpdateUsers


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    UpdateUsers users ->
      { model | users = users } ! []

view : Model -> H.Html (ViewMessage msg)
view model =
  let
    usersHtml = List.map viewUser model.users
    rows = List.reverse (List.foldl rowFolder [] usersHtml)
    rowsHtml = List.map row rows
  in
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
          rowsHtml
        ]
      ]

viewUser : User -> H.Html (ViewMessage msg)
viewUser user =
  H.a
    [ A.class "col-xs-12 col-sm-6 col-md-4 card-link"
    , A.href (Nav.routeToPath (Nav.User user.id))
    , Link.action (Nav.User user.id)
    ]
    [ H.div
      [ A.class "user-card" ]
      [ Common.authorInfoWithLocation user
      , H.hr [] []
      , H.p [] [ H.text (Util.truncateContent user.description 200) ]
      ]
    ]

row : List (H.Html msg) -> H.Html msg
row users =
  H.div
    [ A.class "row list-users__user-row" ]
    users

-- transforms a list to a list of lists of three elements: [1, 2, 3, 4, 5] => [[4, 5], [1, 2, 3]]
-- note: reverse the results if you need the elements to be in original order
rowFolder : a -> List (List a) -> List (List a)
rowFolder x acc =
  case acc of
    [] -> [[x]]
    row :: rows ->
      case row of
        el1 :: el2 :: el3 :: els -> [x] :: row :: rows
        el1 :: el2 :: els -> [el2, el1, x] :: rows
        els -> (x :: els) :: rows
