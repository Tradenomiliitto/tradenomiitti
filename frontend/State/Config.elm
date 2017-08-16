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


degrees : Model -> CategoriedOptions
degrees =
    educationOptions "degree"


specializations : Model -> CategoriedOptions
specializations =
    educationOptions "specialization"


init : Model
init =
    { positionOptions = []
    , domainOptions = []
    , specialSkillOptions = []
    , educationOptions = Dict.empty
    }


finnishRegions : List String
finnishRegions =
    [ "Helsinki"
    , "Jyväskylä"
    , "Kuopio"
    , "Oulu"
    , "Tampere"
    , "Turku"
    , "Vaasa"
    ]


workStatuses : List String
workStatuses =
    [ "Työelämässä"
    , "Vapaalla"
    ]
