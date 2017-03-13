module Profile.Main exposing (..)

import Http
import Json.Decode as Json
import Json.Encode as JS
import Skill
import State.Profile exposing (Model)
import User


type Msg
  = GetMe (Result Http.Error User.User)
  | Save User.User
  | Edit
  | AllowProfileCreation
  | DomainSkillMessage Int Skill.Msg
  | PositionSkillMessage Int Skill.Msg
  | ChangeDomainSelect String
  | ChangePositionSelect String
  | AddDomain
  | AddPosition
  | GetDomainOptions (Result Http.Error (List String))
  | GetPositionOptions (Result Http.Error (List String))
  | ChangePrimaryDomain String
  | ChangePrimaryPosition String
  | ChangeNickname String
  | ChangeDescription String
  | UpdateUser (Result Http.Error ())
  | UpdateConsent (Result Http.Error ())
  | NoOp


getMe : Cmd Msg
getMe =
  Http.get "/api/me" User.userDecoder
    |> Http.send GetMe

initTasks : Cmd Msg
initTasks =
  Cmd.batch [ getPositionOptions, getDomainOptions ]

getDomainOptions : Cmd Msg
getDomainOptions =
  Http.get "/api/domains" (Json.list Json.string)
    |> Http.send GetDomainOptions

getPositionOptions : Cmd Msg
getPositionOptions =
  Http.get "/api/positions" (Json.list Json.string)
    |> Http.send GetPositionOptions

updateMe : User.User -> Cmd Msg
updateMe user =
  put "/api/me" (User.encode user)
    |> Http.send UpdateUser

updateConsent : Cmd Msg
updateConsent =
  Http.post "/api/me/create-profile" Http.emptyBody (Json.succeed ())
    |> Http.send UpdateConsent

put : String -> JS.Value -> Http.Request ()
put url body =
  Http.request
    { method = "PUT"
    , headers = []
    , url = url
    , body = Http.jsonBody body
    , expect = Http.expectStringResponse (\_ -> Ok ())
    , timeout = Nothing
    , withCredentials = False
    }

updateSkillList : Int -> Skill.SkillLevel -> List Skill.Model -> List Skill.Model
updateSkillList index skillLevel list =
  List.indexedMap
    (\i x -> if i == index then Skill.update skillLevel x else x)
    list

deleteFromSkillList : Int -> List Skill.Model -> List Skill.Model
deleteFromSkillList index list =
  List.indexedMap (\i x -> if i == index then Nothing else Just x) list
    |> List.filterMap identity


updateUser : (User.User -> User.User) -> Model -> Model
updateUser update model =
  { model | user = Maybe.map update model.user }

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    GetMe (Err _) ->
      { model | user = Nothing } ! []

    GetMe (Ok user) ->
      { model | user = Just user } ! []

    Save user ->
      model ! [ updateMe user ]

    AllowProfileCreation ->
      let
        newModel = { model | editing = True }
      in
        newModel ! [ updateConsent ]

    Edit ->
      { model | editing = True } ! []

    DomainSkillMessage index (Skill.LevelChange skillLevel) ->
      updateUser (\u -> { u | domains = updateSkillList index skillLevel u.domains }) model ! []

    PositionSkillMessage index (Skill.LevelChange skillLevel) ->
      updateUser (\u -> { u | positions = updateSkillList index skillLevel u.positions }) model ! []

    DomainSkillMessage index Skill.Delete ->
      updateUser (\u -> { u | domains = deleteFromSkillList index u.domains }) model ! []

    PositionSkillMessage index Skill.Delete ->
      updateUser (\u -> { u | positions = deleteFromSkillList index u.positions }) model ! []

    ChangeDomainSelect str ->
      { model | selectedDomainOption = str } ! []

    ChangePositionSelect str ->
      { model | selectedPositionOption = str } ! []

    AddDomain ->
      updateUser (\u -> { u | domains = u.domains ++ [ Skill.Model model.selectedDomainOption Skill.Interested ] }) model ! []

    AddPosition ->
      updateUser (\u -> { u | positions = u.positions ++ [ Skill.Model model.selectedPositionOption Skill.Interested ] }) model ! []

    ChangePrimaryDomain str ->
      updateUser (\u -> { u | primaryDomain = str }) model ! []

    ChangePrimaryPosition str ->
      updateUser (\u -> { u | primaryPosition = str }) model ! []

    ChangeNickname str ->
      updateUser (\u -> { u | name = str }) model ! []

    ChangeDescription str ->
      updateUser (\u -> { u | description = str }) model ! []

    GetPositionOptions (Ok list) ->
      { model | positionOptions = list } ! []

    GetDomainOptions (Ok list) ->
      { model | domainOptions = list } ! []

    GetPositionOptions (Err _) ->
      model ! [] -- TODO error handling

    GetDomainOptions (Err _) ->
      model ! [] -- TODO error handling

    UpdateUser (Err _) ->
      model ! [] -- TODO error handling

    UpdateUser (Ok _) ->
      { model | editing = False } ! []

    UpdateConsent (Err _) ->
      model ! [] -- TODO error handling

    UpdateConsent (Ok _) ->
      let
        newModel =
          { model
            | user = Maybe.map (\u -> { u | profileCreated = True }) model.user
          }
      in
        newModel ! []

    NoOp ->
      model ! []
