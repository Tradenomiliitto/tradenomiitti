module Info exposing (view)

import Html as H
import Html.Attributes as A


view : H.Html msg
view =
  H.div
    [ A.class "container" ]
    [ H.div
      [ A.class "row last-row" ]
      [ H.div
        [ A.class "col-sm-12" ]
        [ H.h1
          [ A.class "info__heading" ]
          [ H.text "Mikä on Tradenomiitti?" ]
        , H.h3
          []
          [ H.text "Tee oma profiili" ]
        , H.p
          []
          [ H.text "Luomalla profiilin tuot oman asiantuntijuutesi esille. Profiilissasi voit määritellä osaamisesi tason ja ilmoittaa myös kiinnostuksenkohteistasi. Vapaalla kuvauksella tuot esille myös omaa persoonaasi! Profiiliisi voit määritellä kokemuksesi eri toimialoilta, tehtäväluokista ja muun erityisosaamisesi. Täytäthän tiedot mahdollisimman kattavasti, jolloin profiilisi löytyy hakutuloksista helpommin ja muut tradenomit pääsevät tutustumaan sinuun! Myös potentiaaliset työnantajat löytävät sinut paremmin, jos profiilisi on huolellisesti täytetty." ]
        , H.p
          []
          [ H.text "Osa tiedoistasi on ennakkotäytetty TRAL:n jäsenrekisteriin ilmoittamiesi tietojen perusteella. Mikäli tiedot eivät ole enää ajan tasalla, pääset Tradenomiitin kautta helposti verkkoasiointiin päivittämään tietosi. Huomioithan, että päivitetyt tiedot näkyvät kahden päivän viiveellä. Jäsenrekisteristä tuodut tiedot eivät näy muille."]
        , H.p
          []
          [ H.text "Profiilissasi näkyy, mitkä tiedoistasi näkyvät vain sinulle. Kirjautumattomille käyttäjille profiilisi näkyy anonyymina, kun taas muille kirjautuneille käyttäjille näkyvät myös ilmoittamasi nimimerkki, profiilikuva ja maakunta. Vaihtamalla muiden käyttäjien kanssa käyntikortteja saat myös heidän yhteystietonsa."]
        , H.p
          []
          [ H.text "Muista myös, että sinun arkesi on toisen unelma. Sinulle merkityksettömältä tuntuva työkokemus voi olla toisen tavoite."]
        , H.h3 [] [ H.text "Hae muita Tradenomeja"]
        , H.p
          []
          [ H.text "Tradenomiitissa pääset selaamaan muita tradenomeja. Voit rajata hakutuloksia muun muassa toimialan, tehtäväluokan ja maakunnan perusteella. Mielenkiintoiselle tradenomille kannattaa ehdottaa käyntikorttien vaihtoa! Hae inspiraatiota ja vinkkejä oman uran suunnitteluun muiden kokemuksista." ]
        , H.p
          []
          [ H.text "Muita tradenomeja voivat selata myös kirjautumattomat käyttäjät. Kirjautumattomille käyttäjille profiilit näkyvät anonyymeinä. Vaikka Tradenomiitti on TRAL:n jäsenille suunnattu palvelu, on se kenen tahansa hyödynnettävissä. Olit sitten opettaja, opo, rekrytoija, esimies tai kuka vain, kannattaa istahtaa hetkeksi alas ja tutustua, mistä kaikesta tradenomien ammattitaito oikeasti koostuu."]
        , H.h3
          []
          [ H.text "Jätä ilmoitus"]
        , H.p
          []
          [ H.text "Tradenomiitissä voit jättää ilmoituksen ja kohdistaa sen haluamallesi käyttäjäryhmälle. Ilmoituksen sisältönä voi olla lähestulkoon mitä vain työelämään liittyvää. Voit esimerkiksi hakea muilta vinkkejä johonkin osaamisalueeseen, kysyä kokemuksia, pyytää apua tai mitä vain mieleen tulee!"]
        , H.p
          []
          [ H.text "Ilmoituksen jättämisen yhteydessä sinun on myös mahdollista määritellä, kenen ensisijaisesti haluat kysymykseen vastaavan. Voit määritellä toimialoja, tehtäväluokkia ja maakuntia, joiden perusteella ilmoituksestasi lähtee sopivimmille vastaajakandidaateille sähköposti-ilmoitus. Ilmoituksesi näkyy Tradenomiitissä kuitenkin kaikille käyttäjille ja kuka tahansa Tradenomiitin käyttäjä voi vastata ilmoitukseesi. Jos et määritä ilmoituksellesi kohderyhmää, ei muille käyttäjille lähetetä ilmoitusta, mutta ilmoituksesi näkyy Tradenomiitissä normaalisti. Omat ilmoituksesi näkyvät myös omassa profiilissasi."]
        , H.p
          []
          [ H.text "Myös kirjautumattomat käyttäjät voivat nähdä kaikki ilmoitukset. He eivät kuitenkaan näe, kuka ilmoituksen on jättänyt ja mitä siihen on vastattu."]
        , H.p
          []
          [ H.text "Mikäli kukaan käyttäjistä ei osaa vastata kysymykseesi, vastaavat Tradenomiliiton asiantuntijat."]
        , H.h3
          []
          [ H.text "Vastaa ilmoituksiin"]
        , H.p
          []
          [ H.text "Kirjautuneena käyttäjänä voit vastata muiden ilmoituksiin. Voit vastata kuhunkin ilmoitukseen yhden kerran, sen jälkeen on suositeltavaa vaihtaa käyntikortteja, mikäli haluatte vielä jatkaa keskustelua. Omaan ilmoitukseesi et voi vastata."]
        , H.p
          []
          [ H.text "Huomioithan, että Tradenomiitti ei ole keskustelupalsta. Laajemmat keskustelut ja verkostoituminen tapahtuu palvelun ulkopuolella, mutta Tradenomiitti tarjoaa edellytykset muiden tradenomien kohtaamiselle ja verkoston kasvattamiselle."]
        , H.h3
          []
          [ H.text "Luo kontakteja"]
        , H.p
          []
          [ H.text "Tradenomiitin tärkein ominaisuus on mahdollisuus luoda kontakteja. Kaikkia Tradenomiitin käyttäjiä yhdistää yksi asia: kaikki ovat tradenomeja. Tarinoita, kokemuksia ja kykyjä sen sijaan on lukemattomia erilaisia. Tuodaan ne kaikki esille!"]
        , H.p
          []
          [ H.text "Tradenomiitti mahdollistaa monipuolisen vuorovaikutuksen. Sparraus, mentorointi, vertaistuki, ideointi, työllistyminen, yhteistyö, muiden auttaminen, oman näkökulman kasvattaminen tai vaikka toisen tradenomin palkkaaminen! Kannustamme kaikkia käyttäjiä tutustumaan muihin ja jakamaan omaa osaamistaan."]
        , H.p
          []
          [ H.text "Kontakteja voit luoda vaihtamalla käyntikortteja muiden käyttäjien kanssa. Kaikki käyttäjät päättävät itse, mitä tietoja heidän käyntikortistaan on saatavilla ja kenelle haluavat käyntikorttinsa jakaa. Vain vastaanottaja voi nähdä lähettäjän käyntikortin. Omaa käyntikorttiaan pääsee muokkaamaan profiilinmuokkauksessa."]
        , H.p
          []
          [ H.text "Huomaa se, että voit aina auttaa toista. Vaikka tuntuisi siltä, että oma osaaminen ei vielä riitä, ei asia kuitenkaan ole niin. Itselle vähäpätöiseltä tuntuva asia voi olla toiselle kullanarvoista tietoa. Olit sitten vasta opintosi aloittanut, vastavalmistunut, asiantuntija tai yritysjohtaja, kokemuksellasi on aina arvoa. Kehitytään yhdessä."]
        , H.h3
          []
          [ H.text "Haluatko palkata tradenomin?"]
        , H.p
          []
          [ H.text "Yrityksillä on mahdollista tehdä Tradenomiitissä suorahakuja. Yritykset voivat saada sovituksi ajaksi tunnukset Tradenomiittiin, jolloin he voivat luoda profiilin ja kontaktoida potentiaalisia tradenomeja."]
        , H.p
          []
          [ H.text "Jos kiinnostuit, ota yhteyttä "
          , H.a
            [ A.href "mailto:tradenomiitti@tral.fi" ]
            [ H.text "tradenomiitti@tral.fi" ]
          ]
        , H.h3
          []
          [ H.text "Yleistä"]
        , H.p
          []
          [ H.text "Tradenomiitti on Tradenomiliitto TRAL ry:n kehittämä palvelu. Tradenomiittiin kirjaudutaan omilla tunnuksilla, jotka ovat jäsennumero ja itse määritelty salasana. Tunnukset ovat samat, joilla myös muihin TRAL:n palveluihin kirjaudutaan. Kirjautuminen tapahtuu SSO-kirjautumisella, jolloin voit yhdellä kirjautumisella käyttää kaikkia TRAL:n palveluja."]
        , H.p
          []
          [ H.text "Tradenomiliitolla on oikeus poistaa asiattomasti käyttäytyvät käyttäjät Tradenomiitistä. Kaikilla käyttäjillä on mahdollisuus ilmoittaa asiattomasta käytöksestä Tradenomiliitolle. Tradenomiitti on TRAL:n tarjoama alusta, mutta kaikki sisältö on jäsenten itse luomaa. Näin ollen Tradenomiliitto ei ole vastuussa jäsenten itsestään ilmoittamien tietojen oikeellisuudesta."]
        , H.p
          [ A.class "info__tral-in-general" ]
          [ H.text "TRAL on kaikkien tradenomien yhteinen työelämän edunvalvonta-, palvelu- ja markkinointiorganisaatio työmarkkinoilla. TRAL:n tehtävänä on myös tehdä tutkintoa tunnetuksi ja edistää tradenomien asemaa työelämässä. TRAL keskittyy tekemään työtä tradenomien etujen ajamiseksi työmarkkinoilla. Meillä on vahva rooli myös ammattikorkeakoulupoliittisissa asioissa: ajamme koko Suomen tradenomien etuja myös koulutuspoliittisissa kysymyksissä."]
        , H.p
          [ A.class "info__tral-in-general"]
          [ H.text "Tutkintopohjaisena liittona TRAL edustaa tradenomeja riippumatta heidän toimialastaan tai työtehtävästään aina opiskeluajoista eläkeikään saakka kaikissa urakehityksen eri vaiheissa."]
        ]
      ]
    ]
