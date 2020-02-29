module Removal exposing (AdLike, Model, Msg(..), Removal, RemovalTarget(..), deleteAd, deleteAnswer, init, update, view)

import Browser.Navigation
import Html as H
import Html.Attributes as A
import Html.Events as E
import List.Extra as List
import Maybe.Extra as Maybe
import Models.User exposing (User)
import Translation exposing (T)
import Util exposing (UpdateMessage(..), ViewMessage(..))


type Msg
    = InitiateRemove Int Int -- index id
    | CancelRemoval Int
    | ConfirmRemoval Int -- id to remove
    | SuccesfullyRemoved


type alias Model =
    { removals : List Removal
    , target : RemovalTarget
    }


type RemovalTarget
    = Ad
    | Answer
    | Profile


init : RemovalTarget -> Model
init target =
    { removals = []
    , target = target
    }


type alias Removal =
    { id : Int
    , index : Int
    }


deleteAd : Int -> Cmd (UpdateMessage Msg)
deleteAd id =
    Util.delete ("/api/ilmoitukset/" ++ String.fromInt id)
        |> Util.errorHandlingSend (always SuccesfullyRemoved)


deleteAnswer : Int -> Cmd (UpdateMessage Msg)
deleteAnswer id =
    Util.delete ("/api/vastaukset/" ++ String.fromInt id)
        |> Util.errorHandlingSend (always SuccesfullyRemoved)


deleteProfile : Cmd (UpdateMessage Msg)
deleteProfile =
    Util.delete "/api/profiilit/oma"
        |> Util.errorHandlingSend (always SuccesfullyRemoved)


update : Msg -> Model -> ( Model, Cmd (UpdateMessage Msg) )
update msg model =
    case msg of
        InitiateRemove index id ->
            ( { model | removals = { index = index, id = id } :: model.removals }
            , Cmd.none
            )

        CancelRemoval index ->
            ( { model | removals = List.filterNot (\removal -> removal.index == index) model.removals }
            , Cmd.none
            )

        ConfirmRemoval id ->
            let
                cmd =
                    case model.target of
                        Ad ->
                            deleteAd id

                        Answer ->
                            deleteAnswer id

                        Profile ->
                            deleteProfile
            in
            ( model
            , cmd
            )

        SuccesfullyRemoved ->
            let
                cmd =
                    case model.target of
                        Ad ->
                            Browser.Navigation.reload

                        Answer ->
                            Browser.Navigation.reload

                        Profile ->
                            Browser.Navigation.load "/?profile-removed"
            in
            ( model
            , cmd
            )


type alias AdLike a b =
    { a
        | id : Int
        , createdBy : { b | id : Int }
    }


confirmationBox t confirmationText iWantToRemoveMy cancelMsg confirmMsg =
    H.div
        [ A.class "removal__confirmation" ]
        [ H.p
            [ A.class "removal__confirmation-text" ]
            [ H.text confirmationText ]
        , H.div
            [ A.class "removal__confirmation-buttons" ]
            [ H.button
                [ A.class "btn removal__confirmation-button-cancel"
                , E.onClick << LocalViewMessage <| cancelMsg
                ]
                [ H.text <| t "common.cancel" ]
            , H.button
                [ A.class "btn btn-primary removal__confirmation-button-confirm"
                , E.onClick << LocalViewMessage <| confirmMsg
                ]
                [ H.text <| iWantToRemoveMy ]
            ]
        ]


view : T -> Maybe User -> Int -> AdLike a b -> Model -> List (H.Html (ViewMessage Msg))
view t userMaybe index ad model =
    let
        ( removeYour, iWantToRemoveMy, confirmationText ) =
            case model.target of
                Ad ->
                    ( t "removal.removeYour.ad"
                    , t "removal.iWantToRemoveMy.ad"
                    , t "removal.confirmationText.ad"
                    )

                Answer ->
                    ( t "removal.iWantToRemoveMy.answer"
                    , t "removal.removeYour.answer"
                    , t "removal.confirmationText.answer"
                    )

                Profile ->
                    ( t "removal.iWantToRemoveMy.profile"
                    , t "removal.removeYour.profile"
                    , t "removal.confirmationText.profile"
                    )

        removals =
            model.removals

        icon =
            H.img
                [ A.class "removal__icon"
                , A.src "/static/close.svg"
                , A.title <| removeYour
                , E.onClick << LocalViewMessage <| InitiateRemove index ad.id
                ]
                []

        isBeingRemoved =
            removals
                |> List.find (\removal -> removal.index == index)
                |> Maybe.isJust
    in
    if Models.User.isAdmin userMaybe || Maybe.map .id userMaybe == Just ad.createdBy.id || model.target == Profile then
        [ H.div
            [ A.class "removal" ]
            [ if not isBeingRemoved then
                icon

              else
                confirmationBox t confirmationText iWantToRemoveMy (CancelRemoval index) (ConfirmRemoval ad.id)
            ]
        ]

    else
        []
