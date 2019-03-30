module State.StaticContent exposing (Model, StaticContent, StaticContentBlock, contentsDecoder, decoder, empty, init)

import Json.Decode as Json
import Json.Decode.Pipeline as P


type alias Model =
    { info : StaticContent
    , terms : StaticContent
    , registerDescription : StaticContent
    }


type alias StaticContent =
    { title : String
    , contents : List StaticContentBlock
    }


type alias StaticContentBlock =
    { heading : Maybe String
    , content : String
    }


empty : StaticContent
empty =
    { title = ""
    , contents = []
    }


init : Model
init =
    { info = empty
    , terms = empty
    , registerDescription = empty
    }


decoder : Json.Decoder StaticContent
decoder =
    Json.succeed StaticContent
        |> P.required "title" Json.string
        |> P.required "contents" contentsDecoder


contentsDecoder : Json.Decoder (List StaticContentBlock)
contentsDecoder =
    Json.succeed StaticContentBlock
        |> P.optional "heading" (Json.maybe Json.string) Nothing
        |> P.required "content" Json.string
        |> Json.list
