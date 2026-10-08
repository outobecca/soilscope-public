# Alkuaineiden Valinta ja Ravinteiden Hallinta

SoilScope sisältää kattavan ravinteiden ja alkuaineiden visualisointi- ja opetusjärjestelmän. Kasvinravinteiden ja maaperän kemiallisten aineiden ymmärtäminen on keskeinen osa SPAC-jatkumon hallintaa.

---

## 🧪 Jaksollinen Järjestelmä (`ElementSelectionModal`)

Sovelluksessa on sisäänrakennettu, responsiivinen jaksollinen järjestelmä:

- **Täysi jaksollinen järjestelmä**: Kaikki 118 alkuainetta järjestettynä standardin mukaisiin jaksoihin ja ryhmiin.
- **Kategoriasuodatus**: Alkuaineet on jaoteltu tieteellisiin kategorioihin (reaktiiviset epämetallit, jalokaasut, alkalimetallit, maa-alkalimetallit, siirtymämetallit, lantanoidit, aktinoidit jne.).
- **Mobiili- ja työpöytäoptimointi**: Modaalilla on automaattinen tilankäytön sovitus, vaakasuuntainen vieritys ja selkeät kosketusalueet myös pienillä älypuhelinten näytöillä.
- **Suora valinta**: Minkä tahansa alkuaineen napautus valitsee kyseisen elementin simulaatiotilaan ja nostaa esiin sen pedagogisen infokortin.

---

## ⚡ Pääravinteiden Pikavalitsimet (`FlutterQuickActions`)

Nopeaa kokeellista analyysia varten alapalkin pikatoiminnoissa on suorat pikanapit kasvin keskeisimmille ravinteille:

| Symboli | Alkuaine | Rooli kasvissa ja maassa |
| :---: | :--- | :--- |
| **N** | Typpi (Nitrogen) | Lehtivihreän, aminohappojen ja proteiinien perusrakenneosa. |
| **P** | Fosfori (Phosphorus) | Energian siirto (ATP), nukleiinihapot ja juuriston kehitys. |
| **K** | Kalium (Potassium) | Ilmarakojen säätely, entsyymiaktivaatio ja osmoottinen paine. |
| **Ca** | Kalsium (Calcium) | Soluseinien lujuus (pektiinit) ja signaalivälitys. |
| **Mg** | Magnesium (Magnesium) | Klorofyllimolekyylin keskusatomi ja fosfaattiaineenvaihdunta. |
| **S** | Rikki (Sulfur) | Rikkipitoiset aminohapot (kysteiini, metioniini) ja proteiinit. |
| **C** | Hiili (Carbon) | Orgaanisen aineksen ja hiilihydraattien runko. |
| **O** | Happi (Oxygen) | Soluhengitys ja hapetus-pelkistysreaktiot. |
| **Fe** | Rauta (Iron) | Elektroninsiirtoketjut ja klorofyllin synteesi. |

---

## 🎨 CPK-Väristandardi

Alkuaineet on koodattu kansainvälisen **CPK-väristandardin** mukaisesti:
- Hiili (C): Musta / tummanharmaa
- Vety (H): Valkoinen
- Happi (O): Punainen
- Typpi (N): Tummansininen
- Fosfori (P): Oranssi
- Rikki (S): Keltainen
- Kalium (K): Violetti
- Kalsium (Ca): Tummanvihreä
- Rauta (Fe): Ruskeanpunainen

---

## 📖 Pedagoginen Infokortti (`HoverTooltip`)

Valitusta alkuaineesta avautuu syventävä analyysikortti, joka sisältää:
- **Tieteellinen kuvaus**: Alkuaineen biokemiallinen merkitys maaperässä ja kasvissa.
- **Biologinen funktio**: Pääasiallinen aineenvaihduntareitti ja vuorovaikutukset.
- **Maaperän ionimuodot**: Kasville käyttökelpoiset ionit (esim. $\text{NO}_3^-$, $\text{NH}_4^+$, $\text{H}_2\text{PO}_4^-$, $\text{K}^+$).
- **Puutosoireet**: Visuaaliset indikaattorit (kloroosi, nekroosi, juurten hidastunut kasvu).
