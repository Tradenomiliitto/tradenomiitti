module ListUsers exposing (..)

import Common exposing (Filter(..))
import Html as H
import Html.Attributes as A
import Html.Events as E
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


sortToString : Sort -> String
sortToString sort =
  case sort of
    Recent -> "recent"
    AlphaAsc -> "alphaAsc"
    AlphaDesc -> "alphaDesc"

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
        |> QueryString.add "order" (sortToString model.sort)
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
  | ChangeSort Sort

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
      if Common.shouldNotGetMoreOnFooter model.users model.cursor
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

    ChangeSort value ->
      reInitItems { model | sort = value }



view : Model -> Config.Model -> Bool -> H.Html (ViewMessage Msg)
view model config isLoggedIn =
  let
    usersHtml = List.map viewUser model.users
    rows = Common.chunk3 usersHtml
    rowsHtml = List.map row rows

    sorterRow = H.map LocalViewMessage <|
      H.div
        [ A.class "row" ]
        [ H.div
          [ A.class "col-xs-12" ]
          [ H.button
              [ A.classList
                  [ ("btn", True)
                  , ("list-users__sorter-button", True)
                  , ("list-users__sorter-button--active", model.sort == Recent)
                  ]
              , E.onClick (ChangeSort Recent)
              ]
              [ H.text "Aktiivisuus"]
          , H.button
              [ A.classList
                  [ ("btn", True)
                  , ("list-users__sorter-button", True)
                  , ("list-users__sorter-button--active"
                    , List.member model.sort [AlphaDesc, AlphaAsc])
                  ]
              , E.onClick (ChangeSort <| if model.sort == AlphaAsc then AlphaDesc else AlphaAsc)
              ]
              [ H.text "Nimi"
              , H.i
                [ A.classList
                  [ ("fa", True)
                  , ("fa-chevron-down", model.sort == AlphaDesc)
                  , ("fa-chevron-up", model.sort /= AlphaDesc)
                  ]
                ] []
              ]
          ]
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
          [ A.class "container" ] <|
          if isLoggedIn then sorterRow :: rowsHtml else rowsHtml
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

