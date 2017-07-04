module State.Config exposing (..)

import Dict exposing (Dict)
import Json.Decode as Json
import Json.Decode.Pipeline as P
import Json.Encode as JS


type alias Model =
    { positionOptions : List String
    , domainOptions : List String
    , specialSkillOptions : CategoriedOptions
    , educationOptions : Education
    , sortingOptions : List ( String, String )
    }


type alias CategoriedOption =
    { category : String, title : String }


type alias CategoriedOptions =
    List CategoriedOption


type alias Education =
    Dict String CategoriedOptions


categoriedOptionsDecoder : Json.Decoder CategoriedOptions
categoriedOptionsDecoder =
    let
        singleDecoder =
            P.decode CategoriedOption
                |> P.required "category" Json.string
                |> P.required "title" Json.string
    in
    Json.list singleDecoder


categoriedOptionsEncode : CategoriedOptions -> JS.Value
categoriedOptionsEncode categoriedOptions =
    categoriedOptions
        |> List.map
            (\option ->
                JS.object
                    [ ( "category", JS.string option.category )
                    , ( "title", JS.string option.title )
                    ]
            )
        |> JS.list


educationOptions : String -> Model -> CategoriedOptions
educationOptions type_ =
    .educationOptions
        >> Dict.get type_
        >> Maybe.withDefault []


institutes : Model -> CategoriedOptions
institutes =
    educationOptions "institute"


degrees : Model -> CategoriedOptions
degrees =
    educationOptions "degree"


majors : Model -> CategoriedOptions
majors =
    educationOptions "major"


specializations : Model -> CategoriedOptions
specializations =
    educationOptions "specialization"


init : Model
init =
    { positionOptions = []
    , domainOptions = []
    , specialSkillOptions = []
    , educationOptions = Dict.empty
    , sortingOptions = []
    }


finnishRegions : List String
finnishRegions =
    [ "Lappi"
    , "Pohjois-Pohjanmaa"
    , "Kainuu"
    , "Pohjois-Karjala"
    , "Pohjois-Savo"
    , "Etelä-Savo"
    , "Etelä-Karjala"
    , "Keski-Suomi"
    , "Etelä-Pohjanmaa"
    , "Pohjanmaa"
    , "Keski-Pohjanmaa"
    , "Pirkanmaa"
    , "Satakunta"
    , "Päijät-Häme"
    , "Kanta-Häme"
    , "Kymenlaakso"
    , "Uusimaa"
    , "Varsinais-Suomi"
    , "Ahvenanmaa"
    ]


sortingOptions : List ( String, String )
sortingOptions =
    [ ( "Uusin ensin", "created_ad_desc" )
    , ( "Vanhin ensin", "created_at_asc" )
    , ( "Eniten vastauksia ensin", "answers_desc" )
    , ( "Vähiten vastauksia ensin", "answers_asc" )
    , ( "Uusin vastaus ensin", "newest_answer_desc" )
    ]
