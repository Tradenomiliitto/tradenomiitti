module State.ListAds exposing (Model, Sort(..), init, limit)

import Models.Ad
import Removal
import State.Settings


type Sort
    = CreatedDesc
    | CreatedAsc
    | AnswerCountDesc
    | AnswerCountAsc
    | NewestAnswerDesc


type alias Model =
    { ads : List Models.Ad.Ad
    , cursor : Int
    , selectedDomain : Maybe String
    , selectedPosition : Maybe String
    , selectedLocation : Maybe String
    , hideJobAds : Bool
    , removal : Removal.Model
    , sort : Sort
    }


limit : Int
limit =
    10


init : State.Settings.Model -> Model
init settings =
    let
        hideJobAds =
            settings.settings
                |> Maybe.map .hide_job_ads
                |> Maybe.withDefault False
    in
    { ads = []
    , cursor = 0
    , selectedDomain = Nothing
    , selectedPosition = Nothing
    , selectedLocation = Nothing
    , hideJobAds = hideJobAds
    , removal = Removal.init Removal.Ad
    , sort = CreatedDesc
    }
