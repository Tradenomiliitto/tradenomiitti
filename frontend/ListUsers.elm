module ListUsers exposing (..)

import Common
import Html as H
import Html.Attributes as A
import Http
import Json.Decode as Json
import Link
import List.Extra as List
import Models.User exposing (User)
import Nav
import State.Config as Config
import State.ListUsers exposing (..)
import Util exposing (ViewMessage(..), UpdateMessage(..))


getUsers : Model -> Cmd (UpdateMessage Msg)
getUsers model =
  let
    url = "/api/profiilit/?limit="
      ++ toString limit
      ++ "&offset="
      ++ toString model.cursor
  in
    Http.get url (Json.list Models.User.userDecoder)
      |> Util.errorHandlingSend UpdateUsers

type Msg
  = UpdateUsers (List User)
  | FooterAppeared

initTasks : Model -> Cmd (UpdateMessage Msg)
initTasks = getUsers


update : Msg -> Model -> (Model, Cmd (UpdateMessage Msg))
update msg model =
  case msg of
    UpdateUsers users ->
      { model
        | users = List.uniqueBy .id <| model.users ++ users
        -- always advance by full amount, so we know when to stop asking for more
        , cursor = model.cursor + limit
      } ! []

    FooterAppeared ->
      if model.cursor > List.length model.users
      then
        model ! []
      else
        model ! [ getUsers model ]

view : Model -> Config.Model -> H.Html (ViewMessage msg)
view model config =
  let
    usersHtml = List.map viewUser model.users
    rows = List.reverse (List.foldl rowFolder [] usersHtml)
    rowsHtml = List.map row rows
    select options =
      H.span
        [ A.class "list-users__select-container" ]
        [ H.select
          [ A.class "list-users__select" ]
          (List.map (\o -> H.option [] [ H.text o]) options)
        ]
  in
    H.div
      []
      [ H.div
        [ A.class "container" ]
        [ H.div
          [ A.class "row" ]
          [ H.div
            [ A.class "col-sm-12" ]
            [ H.h1
              [ A.class "list-users__header" ]
              [ H.text "Selaa tradenomeja" ]
            ]
          ]
        , H.div
          [ A.class "row list-users__filters" ]
          [ H.div
            [ A.class "col-xs-12 col-sm-6" ]
            [ select <| "Valitse toimiala" :: config.domainOptions ]
          , H.div
            [ A.class "col-xs-12 col-sm-6" ]
            [ select <| "Valitse tehtäväluokka" :: config.positionOptions ]
          ]
        ]
      , H.div
        [ A.class "list-users__list-background last-row"]
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
