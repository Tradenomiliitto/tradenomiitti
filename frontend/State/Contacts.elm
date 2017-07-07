module State.Contacts exposing (..)

import Models.User exposing (Contact)


type alias Model =
    { contacts : List Contact
    }


init : Model
init =
    { contacts = []
    }
