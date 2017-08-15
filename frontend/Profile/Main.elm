port module Profile.Main exposing (..)

import Date
import FamilyStatus
import Http
import Json.Decode as Json
import Json.Encode as JS
import List.Extra as List
import Models.Ad
import Models.User exposing (BusinessCard, PictureEditing, User)
import Removal
import Skill
import State.Config as Config
import State.Profile exposing (Model)
import Util exposing (UpdateMessage(..))
import WorkStatus


type Msg
    = GetMe (Result Http.Error User)
    | GetAds (List Models.Ad.Ad)
    | Save User
    | Edit
    | AllowProfileCreation
    | DomainSkillMessage Int Skill.Msg
    | PositionSkillMessage Int Skill.Msg
    | ChangeDomainSelect String
    | ChangePositionSelect String
    | ChangeLocation String
    | ChangeTitle String
    | ChangeWorkStatus (Maybe WorkStatus.WorkStatus)
    | ChangeContributionStatus String
    | ChangeNickname String
    | ChangeDescription String
    | UpdateDate Date.Date
    | UpdateUser ()
    | UpdateConsent
    | UpdateBusinessCard BusinessCardField String
    | ChangeImage User
    | ImageDetailsUpdate ( String, PictureEditing )
    | MouseEnterProfilePic
    | MouseLeaveProfilePic
    | StartAddContact
    | ChangeContactAddingText String
    | AddContact User
    | ShowAll
    | SkillSelected String
    | DeleteSkill String
    | InstituteSelected String
    | DegreeSelected String
    | MajorSelected String
    | SpecializationSelected String
    | AddEducation String
    | DeleteEducation Int
    | RemovalMessage Removal.Msg
    | ChangeBirthMonth String
    | ChangeBirthYear String
    | AddChild
    | DeleteChild Int
    | NoOp


port imageUpload : Maybe PictureEditing -> Cmd msg



-- cropped picture file name and full picture details


port imageSave : (( String, PictureEditing ) -> msg) -> Sub msg


port typeahead : ( String, JS.Value, Bool, Bool, String ) -> Cmd msg


port typeaheadResult : (( String, String ) -> msg) -> Sub msg



-- initialize all autocompletes to empty string


typeaheads : Config.Model -> Cmd msg
typeaheads config =
    Cmd.batch
        [ typeahead ( "skills-input", Config.categoriedOptionsEncode config.specialSkillOptions, True, True, "" )
        , typeahead ( "education-institute", Config.categoriedOptionsEncode << Config.institutes <| config, False, False, "" )
        , typeahead ( "education-degree", Config.categoriedOptionsEncode << Config.degrees <| config, False, True, "" )
        , typeahead ( "education-major", Config.categoriedOptionsEncode << Config.majors <| config, False, True, "" )
        , typeahead ( "education-specialization", Config.categoriedOptionsEncode << Config.specializations <| config, False, True, "" )
        ]


typeAheadToMsg : ( String, String ) -> Msg
typeAheadToMsg ( typeAheadResultStr, id ) =
    case id of
        "skills-input" ->
            SkillSelected typeAheadResultStr

        "education-institute" ->
            InstituteSelected typeAheadResultStr

        "education-degree" ->
            DegreeSelected typeAheadResultStr

        "education-major" ->
            MajorSelected typeAheadResultStr

        "education-specialization" ->
            SpecializationSelected typeAheadResultStr

        _ ->
            NoOp


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ imageSave ImageDetailsUpdate
        , if model.editing then
            typeaheadResult typeAheadToMsg
          else
            Sub.none
        ]


getMe : Cmd (UpdateMessage Msg)
getMe =
    Http.get "/api/profiilit/oma" Models.User.userDecoder
        |> Http.send (LocalUpdateMessage << GetMe)


getAds : User -> Cmd (UpdateMessage Msg)
getAds u =
    Http.get ("/api/ilmoitukset/tradenomilta/" ++ toString u.id) (Json.list Models.Ad.adDecoder)
        |> Util.errorHandlingSend GetAds


initTasks : Cmd (UpdateMessage Msg)
initTasks =
    Cmd.batch
        [ getMe
        , Util.getDate UpdateDate
        ]


updateMe : User -> Cmd (UpdateMessage Msg)
updateMe user =
    Util.put "/api/profiilit/oma" (Models.User.encode user)
        |> Util.errorHandlingSend UpdateUser


updateConsent : Cmd (UpdateMessage Msg)
updateConsent =
    Http.post "/api/profiilit/luo" Http.emptyBody (Json.succeed ())
        |> Util.errorHandlingSend (always UpdateConsent)


updateSkillList : Int -> Skill.SkillLevel -> List Skill.Model -> List Skill.Model
updateSkillList index skillLevel list =
    List.indexedMap
        (\i x ->
            if i == index then
                Skill.update skillLevel x
            else
                x
        )
        list


updateUser : (User -> User) -> Model -> Model
updateUser update model =
    { model | user = Maybe.map update model.user }


type BusinessCardField
    = Name
    | Title
    | Location
    | Phone
    | Email
    | LinkedIn


updateBusinessCard : Maybe BusinessCard -> BusinessCardField -> String -> Maybe BusinessCard
updateBusinessCard businessCard field value =
    case businessCard of
        Just businessCard ->
            case field of
                Name ->
                    Just { businessCard | name = value }

                Title ->
                    Just { businessCard | title = value }

                Location ->
                    Just { businessCard | location = value }

                Phone ->
                    Just { businessCard | phone = value }

                Email ->
                    Just { businessCard | email = value }

                LinkedIn ->
                    Just { businessCard | linkedin = value }

        Nothing ->
            Nothing


update : Msg -> Model -> Config.Model -> ( Model, Cmd (UpdateMessage Msg) )
update msg model config =
    case msg of
        GetMe (Err err) ->
            let
                cmd =
                    case err of
                        Http.BadStatus { status } ->
                            if status.code == 403 || status.code == 401 then
                                Cmd.none
                            else
                                Util.asApiError err

                        _ ->
                            Util.asApiError err
            in
            { model | user = Nothing } ! [ cmd ]

        GetMe (Ok user) ->
            { model | user = Just user } ! [ getAds user ]

        GetAds ads ->
            { model | ads = ads } ! []

        Save user ->
            model ! [ updateMe user ]

        AllowProfileCreation ->
            let
                newModel =
                    { model | editing = True }
            in
            newModel
                ! [ updateConsent
                  , typeaheads config
                  ]

        Edit ->
            { model | editing = True } ! [ typeaheads config ]

        DomainSkillMessage index (Skill.LevelChange skillLevel) ->
            updateUser (\u -> { u | domains = updateSkillList index skillLevel u.domains }) model ! []

        PositionSkillMessage index (Skill.LevelChange skillLevel) ->
            updateUser (\u -> { u | positions = updateSkillList index skillLevel u.positions }) model ! []

        DomainSkillMessage index Skill.Delete ->
            updateUser (\u -> { u | domains = List.removeAt index u.domains }) model ! []

        PositionSkillMessage index Skill.Delete ->
            updateUser (\u -> { u | positions = List.removeAt index u.positions }) model ! []

        ChangeDomainSelect str ->
            updateUser (\u -> { u | domains = List.uniqueBy .heading <| u.domains ++ [ Skill.Model str Skill.Interested ] }) model ! []

        ChangePositionSelect str ->
            updateUser (\u -> { u | positions = List.uniqueBy .heading <| u.positions ++ [ Skill.Model str Skill.Interested ] }) model ! []

        ChangeLocation str ->
            updateUser (\u -> { u | location = str }) model ! []

        ChangeWorkStatus maybeWorkStatus ->
            updateUser (\u -> { u | workStatus = maybeWorkStatus }) model ! []

        ChangeTitle str ->
            updateUser (\u -> { u | title = String.slice 0 70 str }) model ! []

        ChangeContributionStatus str ->
            updateUser (\u -> { u | contributionStatus = String.slice 0 70 str }) model ! []

        ChangeNickname str ->
            updateUser (\u -> { u | name = str }) model ! []

        ChangeDescription str ->
            updateUser (\u -> { u | description = String.slice 0 400 str }) model ! []

        SkillSelected str ->
            updateUser (\u -> { u | skills = List.unique <| u.skills ++ [ str ] }) model
                ! [ typeaheads config ]

        DeleteSkill str ->
            updateUser (\u -> { u | skills = List.filter (\skill -> skill /= str) u.skills }) model
                ! [ typeaheads config ]

        InstituteSelected str ->
            { model | selectedInstitute = Just str } ! []

        DegreeSelected str ->
            { model | selectedDegree = Just str } ! []

        MajorSelected str ->
            { model | selectedMajor = Just str } ! []

        SpecializationSelected str ->
            { model | selectedSpecialization = Just str } ! []

        AddEducation institute ->
            let
                newEducation =
                    { institute = institute
                    , degree = model.selectedDegree
                    , major = model.selectedMajor
                    , specialization = model.selectedSpecialization
                    }
            in
            updateUser (\u -> { u | education = u.education ++ [ newEducation ] })
                { model
                    | selectedInstitute = Nothing
                    , selectedDegree = Nothing
                    , selectedMajor = Nothing
                    , selectedSpecialization = Nothing
                }
                ! [ typeaheads config ]

        DeleteEducation index ->
            updateUser
                (\u -> { u | education = List.removeAt index u.education })
                model
                ! [ typeaheads config ]

        UpdateUser _ ->
            { model | editing = False }
                ! (model.user
                    |> Maybe.map (\user -> [ getAds user ])
                    |> Maybe.withDefault []
                  )

        UpdateBusinessCard field value ->
            updateUser (\u -> { u | businessCard = updateBusinessCard u.businessCard field value }) model ! []

        UpdateConsent ->
            model ! [ getMe ]

        ChangeImage user ->
            model ! [ imageUpload user.pictureEditingDetails ]

        UpdateDate date ->
            { model | currentDate = Just date } ! []

        ImageDetailsUpdate ( cropped, editingDetails ) ->
            updateUser
                (\u ->
                    { u
                        | pictureEditingDetails = Just editingDetails
                        , croppedPictureFileName =
                            if String.length cropped == 0 then
                                Nothing
                            else
                                Just cropped
                    }
                )
                model
                ! []

        MouseEnterProfilePic ->
            { model | mouseOverUserImage = True } ! []

        MouseLeaveProfilePic ->
            { model | mouseOverUserImage = False } ! []

        ChangeBirthMonth str ->
            { model | birthMonth = str } ! []

        ChangeBirthYear str ->
            { model | birthYear = str } ! []

        AddChild ->
            let
                birthdate =
                    Result.map2 FamilyStatus.Birthdate
                        (String.toInt model.birthMonth)
                        (String.toInt model.birthYear)
            in
            case birthdate of
                Ok date ->
                    updateUser (\u -> { u | familyStatus = u.familyStatus ++ [ date ] })
                        { model | birthMonth = "", birthYear = "" }
                        ! []

                Err _ ->
                    model ! []

        DeleteChild index ->
            updateUser (\u -> { u | familyStatus = List.removeAt index u.familyStatus }) model ! []

        -- handled in User
        StartAddContact ->
            model ! []

        ChangeContactAddingText str ->
            model ! []

        AddContact user ->
            model ! []

        ShowAll ->
            { model | viewAllAds = True } ! []

        RemovalMessage msg ->
            let
                ( newRemoval, cmd ) =
                    Removal.update msg model.removal
            in
            { model | removal = newRemoval } ! [ Util.localMap RemovalMessage cmd ]

        NoOp ->
            model ! []
