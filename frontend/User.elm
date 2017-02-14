module User exposing (..)

import Json.Decode exposing (Decoder, string)
import Json.Decode.Pipeline exposing (decode, required, optional)
import Http
import Html exposing (Html, div, text)

type alias User = 
    {
        name: String,
        description: String
    }

userDecoder : Decoder User
userDecoder =
    decode User
        |> required "first_name" string
        |> required "description" string

-- UPDATE 

type Msg = FetchUser Int | UpdateUser (Result Http.Error User)

update : Msg -> Maybe User -> ( Maybe User, Cmd Msg)
update msg user =
    case msg of
        FetchUser userId ->
            (user, getUser userId)

        UpdateUser (Ok updatedUser) ->
            (Just updatedUser, Cmd.none) 

        UpdateUser (Err _) -> 
            (user, Cmd.none)

getUser : Int -> Cmd Msg
getUser userId =
    let 
        url = "/api/user/" ++ (toString userId)
        request = Http.get url userDecoder
    in
        Http.send UpdateUser request


-- VIEW

view : Maybe User -> Html Msg 
view userMaybe =
    userMaybe
        |> Maybe.map viewUser
        |> Maybe.withDefault (div [] [text "spinning"])

  
viewUser : User -> Html Msg
viewUser user =
    div [] 
    [
        div [] [ text user.name ],
        div [] [ text user.description ]
    ]
