module Window exposing (encodeURIComponent)

import Url


encodeURIComponent : String -> String
encodeURIComponent =
    Url.percentEncode
