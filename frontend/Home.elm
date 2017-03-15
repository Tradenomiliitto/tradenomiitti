module Home exposing (..)

import Html as H
import Html.Attributes as A
import ListAds
import State.Home exposing (..)


type Msg = ListAdsMessage ListAds.Msg


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    ListAdsMessage msg ->
      let
        (listAdsModel, cmd) = ListAds.update msg model.listAds
      in
        ({ model | listAds = listAdsModel }, Cmd.map ListAdsMessage cmd)

initTasks : Cmd Msg
initTasks = Cmd.map ListAdsMessage ListAds.getAds


view : Model -> H.Html Msg
view model = 
  H.div 
    []
    [ introScreen
    , listLatestAds model
    ]

-- FIRST INFO SCREEN --

introScreen : H.Html msg
introScreen =
  H.div
    [ A.class "home__intro-screen" ]
    [ introBox ]

introBox : H.Html msg
introBox =
  H.div
    [ A.class "home__introbox col-sm-6 col-sm-offset-3" ]
    [ H.h2 
      [ A.class "home__introbox--heading" ]
      [ H.text "Kohtaa tradenomi" ]
    , H.div
      [ A.class "home__introbox--content" ] 
      [ H.text "Tradenomiitti on tradenomien oma kohtaamispaikka, jossa jäsenet löytävät toisensa yhteisten aiheiden ympäriltä ja hyötyvät toistensa kokemuksista." ]
    , H.button
      [ A.class "home__introbox--button btn btn-primary" ]
      [ H.text "luo oma profiili" ]
    ]

-- LIST LATEST ADS --

listLatestAds : Model -> H.Html Msg
listLatestAds model =
  H.div
    [ A.class "home__latest-ads" ]
    [ H.div
      [ A.class "home__latest-ads--container" ]
      [ listAdsHeading 
      , listFourAds model
      ]
     ]

listAdsHeading : H.Html Msg
listAdsHeading =
  H.div
    [ A.class "home__latest-ads--heading row" ]
    [ listAdsHeader
    , listAdsButtons
    ]

listAdsButtons : H.Html Msg
listAdsButtons =
  H.div
    [ A.class "home__latest-ads--heading--buttons col-sm-6" ]
    [ H.button
      [ A.class "home__latest-ads--heading--buttons--inverse btn btn-primary" ]
      [ H.text "katso kaikki ilmoitukset" ] 
    , H.button
      [ A.class "home__latest-ads--heading--buttons--normal btn btn-primary" ]
      [ H.text "jätä ilmoitus" ]
    ]

listAdsHeader : H.Html Msg
listAdsHeader =
  H.div
    [ A.class "home__latest-ads--heading--text col-sm-6" ]
    [ H.text "Uusimmat ilmoitukset" ]

listFourAds : Model -> H.Html Msg
listFourAds model =
  H.div
    []
    (ListAds.viewAds (List.take 4 model.listAds.ads))