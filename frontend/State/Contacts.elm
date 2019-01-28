module State.Contacts exposing (Model, init)

import Models.User exposing (Contact)


type alias Model =
    { contacts : List Contact
    }


init : Model
init =
    { contacts = []
    }
