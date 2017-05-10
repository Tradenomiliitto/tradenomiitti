module User exposing (..)

import Html as H
import Html.Attributes as A
import Html.Events as E
import Http
import Json.Decode as Json
import Json.Encode as JS
import Link
import Maybe.Extra as Maybe
import Models.Ad exposing (Ad)
import Models.User exposing (User)
import Nav
import Profile.Main as Profile
import Profile.View
import Removal
import State.Config as Config
import State.Profile
import State.User exposing (..)
import SvgIcons
import Util exposing (ViewMessage(..), UpdateMessage(..))


-- UPDATE

type Msg
  = UpdateUser User
  | UpdateAds (List Ad)
  | ProfileMessage Profile.Msg
  | Refresh Int

update : Msg -> Model -> ( Model, Cmd (UpdateMessage Msg))
update msg model =
  case msg of
    UpdateUser updatedUser ->
      { model
        | user = Just updatedUser
        , addingContact = False
      } ! []

    UpdateAds ads ->
      { model | ads = ads } ! []

    ProfileMessage Profile.StartAddContact ->
      { model
        | addingContact = True
        , addContactText = ""
      } ! []
    ProfileMessage (Profile.ChangeContactAddingText str) ->
      { model | addContactText = String.slice 0 1000 str} ! []
    ProfileMessage (Profile.AddContact user) ->
      model ! [ addContact user model.addContactText ]

    ProfileMessage (Profile.RemovalMessage msg) ->
      let
        (newRemoval, cmd) = Removal.update msg model.removal
      in
        { model | removal = newRemoval } ! [ Util.localMap (ProfileMessage << Profile.RemovalMessage) cmd ]

    ProfileMessage Profile.ShowAll ->
      { model | viewAllAds = True } ! []

    ProfileMessage _ ->
      model ! [] -- only handle profile messages that we care about

    Refresh userId ->
      model ! [ getUser userId ]



initTasks : Int -> Cmd (UpdateMessage Msg)
initTasks userId =
  Cmd.batch
    [ getUser userId
    , getAds userId
    ]

getUser : Int -> Cmd (UpdateMessage Msg)
getUser userId =
  let
    url = "/api/profiilit/" ++ toString userId
    request = Http.get url Models.User.userDecoder
  in
    Util.errorHandlingSend UpdateUser request

getAds : Int -> Cmd (UpdateMessage Msg)
getAds userId =
  let
    url = "/api/ilmoitukset/tradenomilta/" ++ toString userId
    request = Http.get url (Json.list Models.Ad.adDecoder)
  in
    Util.errorHandlingSend UpdateAds request

addContact : User -> String -> Cmd (UpdateMessage Msg)
addContact user str =
  let
    encoded =
      JS.object [ ("message", JS.string str)]
  in
    Http.post ("/api/kontaktit/" ++ (toString user.id))
      (Http.jsonBody encoded) (Json.succeed ())
      |> Util.errorHandlingSend (always (Refresh user.id))



-- VIEW

view : Model -> Maybe User -> Config.Model -> H.Html (ViewMessage Msg)
view model loggedInUser config =
  let
    profileInit = State.Profile.init
    profile =
      { profileInit
        | ads = model.ads
        , viewAllAds = model.viewAllAds
        , removal = model.removal
      }
    views = model.user
      |> Maybe.map
        (\u ->
           List.map (Util.localViewMap ProfileMessage) <| Profile.View.viewUser profile False (contactUser model u loggedInUser) config loggedInUser u)
      |> Maybe.withDefault []

  in
   H.div [] views


contactUser : Model -> User -> Maybe User -> H.Html (ViewMessage Profile.Msg)
contactUser model userToContact loggedInUser =
  if userToContact.contacted
  then
    H.div
      [ A.class "col-md-6 user-page__edit-or-contact-user"]
      [ H.p [] [ H.text "Olet lähettänyt käyntikortin tälle tradenomille." ]
      ]
  else
    if model.addingContact
    then
      let
        button =
          H.button
              ([ E.onClick (Profile.AddContact userToContact)
              , A.class "btn btn-primary user-page__contact-send"
              , A.disabled
                (String.length model.addContactText < 10
                    || not (maybeUserCanSendBusinessCard loggedInUser)
                )
              ] ++
                if maybeUserCanSendBusinessCard loggedInUser
                then []
                else [ A.title "Käyntikortissasi täytyy olla vähintään puhelinnumero tai sähköpostiosoite, jotta voisit lähettää sen" ])
              [ H.text "Lähetä" ]
        popover =
          case (loggedInUser, Maybe.andThen .businessCard loggedInUser) of
            (Just user, Just businessCard) ->
              H.div
                [ A.class "popover__container" ]
                [ H.div
                  [ A.class "popover__trigger user-page__businesscard" ]
                  [ H.span [ A.class "user-page__businesscard-icon" ]
                    [ SvgIcons.businessCard ]
                  , H.span [ A.class "user-page__businesscard-text" ]
                    [ H.text "Viestin mukana lähetät käyntikortin" ]
                  , H.div
                    [ A.class "popover__content" ]
                    [ Profile.View.businessCardView user businessCard ]
                  ]
                ]
            _ ->
              H.div [] []
      in
        H.div
          [ A.class "col-md-6 user-page__edit-or-contact-user"]
          [ H.p [ A.class "user-apge__edit-or-contact-user-prompt"] [ H.text "Kirjoita napakka esittelyteksti"]
          , H.map LocalViewMessage <| H.textarea
            [ A.placeholder "Vähintään 10 merkkiä"
            , A.class "user-page__add-contact-textcontent"
            , E.onInput Profile.ChangeContactAddingText
            , A.value model.addContactText
            ] []
          , H.div
            []
            [ popover
            , H.map LocalViewMessage button
            ]
          ]
    else
      H.div
        [ A.class "col-md-6 user-page__edit-or-contact-user"]
        [ H.p [] [ H.text ("Voisiko " ++ userToContact.name ++ " auttaa sinua? Jaa käyntikorttisi tästä. ") ]
        , H.button
          [ if Maybe.isJust loggedInUser then
              E.onClick <| LocalViewMessage Profile.StartAddContact
            else
              Link.action (Nav.LoginNeeded (Nav.User userToContact.id |> Nav.routeToPath |> Just))
          , A.class "btn btn-primary"
          ] [ H.text "Ota yhteyttä" ]
        ]

maybeUserCanSendBusinessCard : Maybe User -> Bool
maybeUserCanSendBusinessCard maybeUser =
  maybeUser
    |> Maybe.andThen .businessCard
    |> Maybe.map (\card -> String.length card.phone > 0 || String.length card.email > 0)
    |> Maybe.withDefault False
