module State.Config exposing (..)

type alias Model =
  { positionOptions : List String
  , domainOptions : List String
  }


init : Model
init =
  { positionOptions = []
  , domainOptions = []
  }
