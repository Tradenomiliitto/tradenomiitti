module ListUsers exposing (..)

import Common exposing (Filter(..))
import Html as H
import Html.Attributes as A
import Http
import Json.Decode as Json
import Link
import List.Extra as List
import Models.User exposing (User)
import Nav
import QueryString
import QueryString.Extra as QueryString
import State.Config as Config
import State.ListUsers exposing (..)
import Util exposing (ViewMessage(..), UpdateMessage(..))


getUsers : Model -> Cmd (UpdateMessage Msg)
getUsers model =
  let
    queryString =
      QueryString.empty
        |> QueryString.add "limit" (toString limit)
        |> QueryString.add "offset" (toString model.cursor)
        |> QueryString.optional "domain" model.selectedDomain
        |> QueryString.optional "position" model.selectedPosition
        |> QueryString.optional "location" model.selectedLocation
        |> QueryString.render

    url = "/api/profiilit/" ++ queryString
  in
    Http.get url (Json.list Models.User.userDecoder)
      |> Util.errorHandlingSend UpdateUsers

type Msg
  = UpdateUsers (List User)
  | FooterAppeared
  | ChangeDomainFilter (Maybe String)
  | ChangePositionFilter (Maybe String)
  | ChangeLocationFilter (Maybe String)

initTasks : Model -> Cmd (UpdateMessage Msg)
initTasks = getUsers


reInitItems : Model -> (Model, Cmd (UpdateMessage Msg))
reInitItems model =
  let
    newModel = { model | users = [], cursor = 0 }
  in
    newModel ! [ getUsers newModel ]

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

    ChangeDomainFilter value ->
      reInitItems { model | selectedDomain = value }

    ChangePositionFilter value ->
      reInitItems { model | selectedPosition = value }

    ChangeLocationFilter value ->
      reInitItems { model | selectedLocation = value }



view : Model -> Config.Model -> H.Html (ViewMessage Msg)
view model config =
  let
    usersHtml = List.map viewUser model.users
    rows = chunk3 usersHtml
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
            [ H.h1
              [ A.class "list-users__header" ]
              [ H.text "Selaa tradenomeja" ]
            ]
          ]
        , H.div
          [ A.class "row list-users__filters" ]
          [ H.div
            [ A.class "col-xs-12 col-sm-4" ]
            [ Common.select "list-users" (LocalViewMessage << ChangeDomainFilter) Domain config.domainOptions model ]
          , H.div
            [ A.class "col-xs-12 col-sm-4" ]
            [ Common.select "list-users" (LocalViewMessage << ChangePositionFilter) Position config.positionOptions model ]
          , H.div
            [ A.class "col-xs-12 col-sm-4" ]
            [ Common.select "list-users" (LocalViewMessage << ChangeLocationFilter) Location Config.finnishRegions model ]
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
    [ A.class "col-xs-12 col-sm-4 card-link list-users__item-container"
    , A.href (Nav.routeToPath (Nav.User user.id))
    , Link.action (Nav.User user.id)
    ]
    [ H.div
      [ A.class "user-card list-users__item" ]
      [ Common.authorInfoWithLocation user
      , H.hr [ A.class "list-users__item-ruler"] []
      , H.p [] [ H.text (Util.truncateContent user.description 200) ]
      ]
    ]

row : List (H.Html msg) -> H.Html msg
row users =
  H.div
    [ A.class "row list-users__user-row list-users__row" ]
    users

chunk3 : List a -> List (List a)
chunk3 = List.reverse << List.foldl rowFolder []

-- transforms a list to a list of lists of three elements: [1, 2, 3, 4, 5] => [[4, 5], [1, 2, 3]]
-- note: reverse the results if you need the elements to be in original order
rowFolder : a -> List (List a) -> List (List a)
rowFolder x acc =
  case acc of
    [] -> [[x]]
    row :: rows ->
      case row of
        el1 :: el2 :: el3 :: els -> [x] :: row :: rows
        el1 :: el2 :: els -> [el1, el2, x] :: rows
        el1 :: els -> [el1, x] :: rows
        els -> ([x]) :: rows
