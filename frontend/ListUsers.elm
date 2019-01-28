module ListUsers exposing (Msg(..), emptyToNothing, getUsers, initTasks, reInitItems, row, sortToString, subscriptions, typeAheadToMsg, typeaheads, update, view, viewUser)

import Common exposing (Filter(..))
import Dict
import Html as H
import Html.Attributes as A
import Html.Events as E
import Http
import Json.Decode as Json
import Json.Encode as JS
import Link
import List.Extra as List
import Models.User exposing (User)
import Nav
import Profile.Main exposing (typeahead, typeaheadResult)
import QS
import State.Config as Config
import State.ListUsers exposing (..)
import Translation exposing (T)
import Util exposing (UpdateMessage(..), ViewMessage(..), qsOptional)


sortToString : Sort -> String
sortToString sort =
    case sort of
        Recent ->
            "recent"

        AlphaAsc ->
            "alphaAsc"

        AlphaDesc ->
            "alphaDesc"



-- initialize typeaheads, don't clear any of them on selection and don't show "add new" section


typeaheads : Model -> Config.Model -> Cmd msg
typeaheads model config =
    Cmd.batch
        [ typeahead <| JS.list identity [ JS.string "skills-input", Config.categoriedOptionsEncode config.specialSkillOptions, JS.bool False, JS.bool False, JS.string model.selectedSkill ]
        , typeahead <| JS.list identity [ JS.string "education-institute", Config.categoriedOptionsEncode << Config.institutes <| config, JS.bool False, JS.bool False, JS.string model.selectedInstitute ]
        , typeahead <| JS.list identity [ JS.string "education-specialization", Config.categoriedOptionsEncode << Config.specializations <| config, JS.bool False, JS.bool False, JS.string model.selectedSpecialization ]
        ]


typeAheadToMsg : ( String, String ) -> Msg
typeAheadToMsg ( typeAheadResultStr, id ) =
    case id of
        "skills-input" ->
            ChangeSkillFilter typeAheadResultStr

        "education-institute" ->
            ChangeInstituteFilter typeAheadResultStr

        "education-specialization" ->
            ChangeSpecializationFilter typeAheadResultStr

        _ ->
            NoOp



-- this is unuconditional here, but conditional in the top level on ListUsers being active


subscriptions : Sub Msg
subscriptions =
    Sub.batch
        [ typeaheadResult typeAheadToMsg
        ]


emptyToNothing : String -> Maybe String
emptyToNothing str =
    if String.length str == 0 then
        Nothing

    else
        Just str


getUsers : Model -> Cmd (UpdateMessage Msg)
getUsers model =
    let
        queryString =
            Dict.empty
                |> Dict.insert "limit" (QS.One <| QS.Str <| String.fromInt limit)
                |> Dict.insert "offset" (QS.One <| QS.Str <| String.fromInt model.cursor)
                |> qsOptional "domain" model.selectedDomain
                |> qsOptional "position" model.selectedPosition
                |> qsOptional "location" model.selectedLocation
                |> qsOptional "special_skill" (emptyToNothing model.selectedSkill)
                |> qsOptional "specialization" (emptyToNothing model.selectedSpecialization)
                |> qsOptional "institute" (emptyToNothing model.selectedInstitute)
                |> Dict.insert "order" (QS.One <| QS.Str <| sortToString model.sort)
                |> QS.serialize QS.config

        url =
            "/api/profiilit/" ++ queryString
    in
    Http.get url (Json.list Models.User.userDecoder)
        |> Util.errorHandlingSend UpdateUsers


type Msg
    = UpdateUsers (List User)
    | FooterAppeared
    | ChangeDomainFilter (Maybe String)
    | ChangePositionFilter (Maybe String)
    | ChangeLocationFilter (Maybe String)
    | ChangeInstituteFilter String
    | ChangeSpecializationFilter String
    | ChangeSkillFilter String
    | ChangeSort Sort
    | NoOp


initTasks : Model -> Cmd (UpdateMessage Msg)
initTasks =
    getUsers


reInitItems : Model -> ( Model, Cmd (UpdateMessage Msg) )
reInitItems model =
    let
        newModel =
            { model | users = [], cursor = 0, receivedCount = 0 }
    in
    ( newModel
    , getUsers newModel
    )


update : Msg -> Model -> ( Model, Cmd (UpdateMessage Msg) )
update msg model =
    case msg of
        UpdateUsers users ->
            ( { model
                | users = List.uniqueBy .id <| model.users ++ users

                -- always advance by full amount, so we know when to stop asking for more
                , receivedCount = model.receivedCount + List.length users
                , cursor = model.cursor + limit
              }
            , Cmd.none
            )

        FooterAppeared ->
            if Common.shouldNotGetMoreOnFooter model.receivedCount model.cursor then
                ( model
                , Cmd.none
                )

            else
                ( model
                , getUsers model
                )

        ChangeDomainFilter value ->
            reInitItems { model | selectedDomain = value }

        ChangePositionFilter value ->
            reInitItems { model | selectedPosition = value }

        ChangeLocationFilter value ->
            reInitItems { model | selectedLocation = value }

        ChangeInstituteFilter value ->
            reInitItems { model | selectedInstitute = value }

        ChangeSpecializationFilter value ->
            reInitItems { model | selectedSpecialization = value }

        ChangeSkillFilter value ->
            reInitItems { model | selectedSkill = value }

        ChangeSort value ->
            reInitItems { model | sort = value }

        NoOp ->
            ( model
            , Cmd.none
            )


view : T -> Model -> Config.Model -> Bool -> H.Html (ViewMessage Msg)
view t model config isLoggedIn =
    let
        usersHtml =
            List.map viewUser model.users

        rows =
            Common.chunk3 usersHtml

        rowsHtml =
            List.map row rows

        sorterRow =
            H.map LocalViewMessage <|
                H.div
                    [ A.class "row" ]
                    [ H.div
                        [ A.class "col-xs-12" ]
                        [ H.button
                            [ A.classList
                                [ ( "btn", True )
                                , ( "list-users__sorter-button", True )
                                , ( "list-users__sorter-button--active", model.sort == Recent )
                                ]
                            , E.onClick (ChangeSort Recent)
                            ]
                            [ H.text <| t "listUsers.sort.activity" ]
                        , H.button
                            [ A.classList
                                [ ( "btn", True )
                                , ( "list-users__sorter-button", True )
                                , ( "list-users__sorter-button--active"
                                  , List.member model.sort [ AlphaDesc, AlphaAsc ]
                                  )
                                ]
                            , E.onClick
                                (ChangeSort <|
                                    if model.sort == AlphaAsc then
                                        AlphaDesc

                                    else
                                        AlphaAsc
                                )
                            ]
                            [ H.text <| t "listUsers.sort.name"
                            , H.i
                                [ A.classList
                                    [ ( "fa", True )
                                    , ( "fa-chevron-down", model.sort == AlphaDesc )
                                    , ( "fa-chevron-up", model.sort /= AlphaDesc )
                                    ]
                                ]
                                []
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
                        [ H.text <| t "listUsers.heading" ]
                    ]
                ]
            , H.div
                [ A.class "row list-users__filters" ]
                [ H.div
                    [ A.class "col-xs-12 col-sm-4" ]
                    [ Common.select t "list-users" (LocalViewMessage << ChangeDomainFilter) Domain config.domainOptions model ]
                , H.div
                    [ A.class "col-xs-12 col-sm-4" ]
                    [ Common.select t "list-users" (LocalViewMessage << ChangePositionFilter) Position config.positionOptions model ]
                , H.div
                    [ A.class "col-xs-12 col-sm-4" ]
                    [ Common.select t "list-users" (LocalViewMessage << ChangeLocationFilter) Location Config.finnishRegions model ]
                ]
            , H.div
                [ A.class "row list-users__filters" ]
                [ H.div
                    [ A.class "col-xs-12 col-sm-4" ]
                    [ Common.typeaheadInput "list-users__" (t "listUsers.filters.institute") "education-institute" ]
                , H.div
                    [ A.class "col-xs-12 col-sm-4" ]
                    [ Common.typeaheadInput "list-users__" (t "listUsers.filters.specialization") "education-specialization" ]
                , H.div
                    [ A.class "col-xs-12 col-sm-4" ]
                    [ Common.typeaheadInput "list-users__" (t "listUsers.filters.skill") "skills-input" ]
                ]
            ]
        , H.div
            [ A.class "list-users__list-background last-row" ]
            [ H.div
                [ A.class "container" ]
              <|
                if isLoggedIn then
                    sorterRow :: rowsHtml

                else
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
            , H.hr [ A.class "list-users__item-ruler" ] []
            , H.p [] [ H.text (Util.truncateContent user.description 200) ]
            ]
        ]


row : List (H.Html msg) -> H.Html msg
row users =
    H.div
        [ A.class "row list-users__user-row list-users__row" ]
        users
