module CreateAd exposing (..)

import Common exposing (Filter(..))
import Html as H
import Html.Attributes as A
import Html.Events as E
import Http
import Json.Decode as Json
import Json.Encode as JS
import Nav
import State.Config as Config
import State.CreateAd exposing (..)
import State.Util exposing (SendingStatus(..))
import Translation exposing (T)
import Util exposing (UpdateMessage(..))


type Msg
    = NoOp
    | ChangeHeading String
    | ChangeContent String
    | ChangeDomain (Maybe String)
    | ChangePosition (Maybe String)
    | ChangeLocation (Maybe String)
    | Send
    | SendResponse (Result Http.Error Int)


sendAd : Model -> Cmd Msg
sendAd model =
    let
        encoded =
            JS.object <|
                [ ( "heading", JS.string model.heading )
                , ( "content", JS.string model.content )
                ]
                    ++ List.filterMap identity
                        [ Maybe.map (\value -> ( "domain", JS.string value )) model.selectedDomain
                        , Maybe.map (\value -> ( "position", JS.string value )) model.selectedPosition
                        , Maybe.map (\value -> ( "location", JS.string value )) model.selectedLocation
                        ]
    in
    Http.post "/api/ilmoitukset" (Http.jsonBody encoded) Json.int
        |> Http.send SendResponse


update : Msg -> Model -> ( Model, Cmd (UpdateMessage Msg) )
update msg model =
    case msg of
        ChangeHeading str ->
            { model | heading = String.filter ((/=) '\n') str } ! []

        ChangeContent str ->
            { model | content = str } ! []

        ChangeDomain value ->
            { model | selectedDomain = value } ! []

        ChangePosition value ->
            { model | selectedPosition = value } ! []

        ChangeLocation value ->
            { model | selectedLocation = value } ! []

        Send ->
            { model | sending = Sending } ! [ Cmd.map LocalUpdateMessage <| sendAd model ]

        SendResponse (Err _) ->
            { model | sending = FinishedFail } ! []

        SendResponse (Ok id) ->
            init
                ! [ Util.reroute (Nav.ShowAd id) ]

        NoOp ->
            model ! []


minHeading : Int
minHeading =
    4


maxHeading : Int
maxHeading =
    90


view : T -> Config.Model -> Model -> H.Html Msg
view t config model =
    case model.sending of
        NotSending ->
            H.div
                [ A.class "container last-row" ]
                [ H.div
                    [ A.class "row create-ad" ]
                    [ H.div
                        [ A.class "col-xs-12 col-sm-7 create-ad__inputs" ]
                        [ H.h3
                            [ A.class "create-ad__heading-input" ]
                            [ H.textarea
                                [ A.placeholder "Otsikko"
                                , E.onInput ChangeHeading
                                , A.value model.heading
                                , A.wrap "soft"
                                , A.rows 1
                                ]
                                []
                            ]
                        , Common.lengthHint t "create-ad__heading-length-hint" model.heading minHeading maxHeading
                        , H.textarea
                            [ A.placeholder "Kirjoita ytimekäs ilmoitus"
                            , A.class "create-ad__textcontent"
                            , E.onInput ChangeContent
                            , A.value model.content
                            ]
                            []
                        ]
                    , H.div
                        [ A.class "col-xs-12 col-sm-5 create-ad__filters-submit" ]
                        [ H.h3
                            [ A.class "create-ad__filters-heading" ]
                            [ H.text "Kenen toivot vastaavan?" ]
                        , H.p [] [ H.text "Valitsemalla toimialan tai tehtävän varmistat, että kysymyksesi löytää vastaajansa. Valittu kohderyhmä saa myös ilmoituksesi sähköpostina." ]
                        , Common.select t "create-ad" ChangeDomain Domain config.domainOptions model
                        , Common.select t "create-ad" ChangePosition Position config.positionOptions model
                        , Common.select t "create-ad" ChangeLocation Location Config.finnishRegions model
                        , H.p
                            [ A.class "create-ad__submit-button" ]
                            [ H.button
                                [ A.class "btn btn-primary"
                                , E.onClick Send
                                , A.disabled (String.length model.heading < minHeading || String.length model.heading > maxHeading)
                                ]
                                [ H.text "Julkaise ilmoitus" ]
                            ]
                        ]
                    ]
                ]

        Sending ->
            H.div
                [ A.class "splash-screen" ]
                [ H.div
                    [ A.class "loader" ]
                    []
                ]

        FinishedSuccess id ->
            H.div
                [ A.class "splash-screen " ]
                [ H.div [ A.class "create-ad__success" ]
                    [ H.h1 [] [ H.text "Lähetys onnistui" ]
                    , H.p [] [ H.text <| "Ilmoituksen numero on: " ++ id ]
                    , H.p [] [ H.text "Paina selaimesi päivitä-nappulaa jatkaaksesi" ]
                    ]
                ]

        FinishedFail ->
            H.div
                [ A.class "splash-screen" ]
                [ H.div [ A.class "create-ad__fail" ]
                    [ H.h1 [] [ H.text "Jotain meni pieleen" ]
                    , H.p [] [ H.text "Ole hyvä ja lataa sivu uudelleen" ]
                    ]
                ]
