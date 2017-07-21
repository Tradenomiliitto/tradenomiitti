module Skill exposing (..)

import Html as H
import Html.Attributes as A
import Html.Events as E
import Json.Decode as Json
import Json.Decode.Pipeline as P
import Json.Encode as JS
import Translation exposing (T)


type SkillLevel
    = Interested
    | Beginner
    | Experienced
    | Pro


type Msg
    = LevelChange SkillLevel
    | Delete


type alias Model =
    { heading : String
    , skillLevel : SkillLevel
    }


decoder : Json.Decoder Model
decoder =
    P.decode Model
        |> P.required "heading" Json.string
        |> P.required "skill_level" skillLevelDecoder


encode : Model -> JS.Value
encode model =
    JS.object
        [ ( "heading", JS.string model.heading )
        , ( "skill_level", JS.int (skillToInt model.skillLevel) )
        ]


skillLevelDecoder : Json.Decoder SkillLevel
skillLevelDecoder =
    let
        intToSkill num =
            case num of
                1 ->
                    Json.succeed Interested

                2 ->
                    Json.succeed Beginner

                3 ->
                    Json.succeed Experienced

                4 ->
                    Json.succeed Pro

                _ ->
                    Json.fail "Taitotasolle ei löytynyt vastaavuutta"
    in
    Json.int
        |> Json.andThen intToSkill


allSkills : List SkillLevel
allSkills =
    [ Interested, Beginner, Experienced, Pro ]


update : SkillLevel -> Model -> Model
update skillLevel model =
    { model | skillLevel = skillLevel }


skillToInt : SkillLevel -> Int
skillToInt skillLevel =
    case skillLevel of
        Interested ->
            1

        Beginner ->
            2

        Experienced ->
            3

        Pro ->
            4


view : T -> Bool -> Model -> H.Html Msg
view t editing model =
    let
        skillText =
            case model.skillLevel of
                Interested ->
                    t "skill.interested"

                Beginner ->
                    t "skill.beginner"

                Experienced ->
                    t "skill.experienced"

                Pro ->
                    t "skill.pro"

        skillNumber =
            skillToInt model.skillLevel

        circle type_ skillLevel =
            H.span
                [ A.class <| "skill__circle-container skill__circle-container--" ++ type_
                ]
                [ H.span
                    ([ A.class <|
                        (if editing then
                            "skill__circle--clickable "
                         else
                            ""
                        )
                            ++ "skill__circle skill__circle--"
                            ++ type_
                     ]
                        ++ (if editing then
                                [ E.onClick (LevelChange skillLevel) ]
                            else
                                []
                           )
                    )
                    []
                ]

        filledCircle =
            circle "filled"

        activeCircle =
            circle "active"

        unFilledCircle =
            circle "unfilled"
    in
    H.div
        [ A.class "row" ]
    <|
        [ H.div
            [ A.class "col-xs-10 col-sm-8 col-md-8 col-lg-6" ]
            [ H.p
                []
                [ H.span [ A.class "skill__heading" ] [ H.text model.heading ]
                , H.span [ A.class "skill__level-text" ] [ H.text skillText ]
                ]
            , H.p
                []
                [ H.input
                    [ A.value (toString skillNumber)
                    , A.type_ "text"
                    , A.class "skill__input"
                    ]
                    []
                , H.span [] <|
                    (List.take (skillNumber - 1) allSkills |> List.map filledCircle)
                        ++ (List.drop (skillNumber - 1) allSkills |> List.take 1 |> List.map activeCircle)
                        ++ (List.drop skillNumber allSkills |> List.map unFilledCircle)
                ]
            ]
        ]
            ++ (if editing then
                    [ H.div
                        [ A.class "col-xs-1 col-sm-2 skill__delete" ]
                        [ H.i
                            [ A.class "skill__delete-icon fa fa-remove"
                            , E.onClick Delete
                            ]
                            []
                        ]
                    ]
                else
                    []
               )
