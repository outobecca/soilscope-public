# Käyttöohje (User Guide)

Tämä opas neuvoo **SoilScope**-simulaattorin käyttöliittymän, ohjainten ja analyysityökalujen käytön vaihe vaiheelta.

---

## 🖥️ 1. Päänäkymä ja Käyttöliittymän Rakenne

SoilScopen käyttöliittymä koostuu interaktiivisesta pelimaailmasta ja sitä ympäröivistä kelluvista ohjainpaneeleista:

1. **Simulaatiomaailma (Keskellä)**:
   - Visualisoi kasvin verson, juuriston, maaprofiilin eri kerrokset ja biologiset prosessit (veden virtaus, ravinteet, mikrobit, kaasukuplat).
   - **Kamera**: Voit liikuttaa näkymää raahaamalla ja lähentää/loitontaa hiiren rullalla tai nipistämällä kosketusnäytöllä.
   - **Hotspot-pisteet**: Klikkaamalla maaperän ja kasvin osia saat esiin reaaliaikaisen diagnostisen tietokortin.

2. **Yläpalkki (Gamification & Tilannekatsaus)**:
   - Näyttää simulaation pisteytyksen, maaperän terveysindeksin (Soil Health Score) ja aktiivisen skenaarion tilan.
   - Vasemmasta yläkulmasta avautuu **Dashboard (Ohjauspaneeli)**.
   - Oikeasta yläkulmasta avautuvat **Asetukset ja Simulaatio-ohjaimet**.

3. **Alapalkki (Quick Actions & Työkalut)**:
   - Pääsy usein käytettyihin toimintoihin: simulaationopeus, sää, muokkaus, lannoitus, mikroskooppi ja ravinteet.

---

## ⏯️ 2. Simulaation Ohjaus ja Aikajana

- **Käynnistä / Pysäytä**: Pysäytä tai jatka simulaatiota alapalkin tai säätövalikon toistopainikkeella.
- **Simulaationopeus (Time Scale)**: Paina nopeusnappia (`1.0x`) vaihtaaksesi laskentanopeutta: `0.5x`, `1.0x`, `2.0x`, `5.0x` tai `10.0x`.
- **Aikajana (Timeline Slider)**:
  - Aktivoi aikajana-työkalu, jos haluat tarkastella aiempia simulaation vaiheita tai kelata tapahtumia ajassa taaksepäin.

---

## 🌧️ 3. Ympäristön ja Maaperän Hoitotoimenpiteet

Voit suorittaa maaperälle ja kasville toimenpiteitä suoraan alapalkista:

### 💧 Sadetus ja Kuivuus (Rain)
- Napauta vesipisara-painiketta käynnistääksesi sateen ($10\text{ mm/h}$) tai kytkeäksesi sen pois.
- Voit myös kytkeä automaattisen säädynamiikan (**Auto Weather**) päälle/pois.

### 🚜 Maan Muokkaus (Tillage)
- Suorittaa maan mekaanisen muokkauksen.
- *Huomioi biofysiikka*: Muokkaus kuohkeuttaa tiivistynyttä maata, mutta liian märässä maassa suoritettu muokkaus rikkoo maaperän murenarakenteen ja tuhoaa 80 % sienirihmastoista.

### 🌿 Peitekasvi (Cover Crop)
- Kylvää maaperään peitekasvuston, joka lisää orgaanista ainesta, sitoo typpeä ja suojaa eroosiolta.

### 🧪 Lannoitus ja Ravinteiden Lisäys (Fertilize)
- Avaa lannoitusikkunan (**Fertilizer Modal**), josta voit lisätä maahan orgaanista typpeä, mineraalilannoitteita tai kompostia.

---

## 🔬 4. Nanovision-Mikroskoopin Käyttö

1. **Aktivointi**: Paina alapalkin mikroskooppikuvaketta (`Biotech`).
2. **Kelluva HUD-ohjain**:
   - Ruudun yläosaan ilmestyy **NANOVISION**-ohjainpaneeli.
   - Voit siirtyä suoraan napauttamalla eri solutasoille:
     - **Lehti (400x)**: Tarkastele ilmarakoja ja fotosynteesin turgoria.
     - **Varsi (200x)**: Seuraa johtojänteiden nestevirtauksia.
     - **Kärkimeristeemi (800x)**: Tutki kasvupisteen solunjakautumista ja kantasoluja.
     - **Juuri (400x)**: Näe juurikarvat ja Casparyn vyö.
     - **Ritsosfääri (600x)**: Analysoi juurieritteitä ja mikrobistoa.
     - **Mikrobi (1200x)**: Tarkastele bakteerin aineenvaihduntaa ja soluhengitystä.
     - **Maan rakenne (250x)**: Tutki aggregaattien stabiliteettia ja huokosia.
3. **Opettavainen Infokortti**: Klikkaa HUD-paneelin info-painiketta (`ℹ️`) avataksesi kohteen matemaattisen ja biokemiallisen yhtälökortin.
4. **Sulkeminen**: Napauta HUD-paneelin rasti-painiketta (`✕`).

---

## 📊 5. Alkuaineiden ja Ravinteiden Tarkastelu

- **Pikanapit**: Alapalkissa on näkyvissä tärkeimmät kasviravinteet: **N, P, K, Ca, Mg, S, C, O, Fe**.
- **Jaksollinen järjestelmä**: Paina ruudukkopainiketta (`⊞`) avataksesi täyden jaksollisen järjestelmän.
- **Valinnan vaikutus**: Kun valitset tietyn alkuaineen:
  1. Simulaatio korostaa kyseisen elementin ionit ja virtaukset maaperässä.
  2. Ruudulle aukeaa **HoverTooltip**-kortti, joka kertoo alkuaineen CPK-värin, biologisen roolin, ionimuodot ja puutosoireet.
- **Valinnan nollaus**: Paina uudelleen aktiivista elementtiä tai "Tyhjennä valinta".

---

## 📈 6. Dashboard, Tieteelliset Graafit ja Logic Lab

### Dashboard (Vasen sivupalkki)
- **Layer Diagnostics**: Tarkastele kunkin maakerroksen ($0{-}10\text{ cm}$, $10{-}20\text{ cm}$ jne.) kosteutta, lämpötilaa, pH-arvoa, redokstilaa ($Eh$) ja orgaanista hiiltä.
- **Mollier & PAR**: Ilmakehän suhteellinen kosteus, VPD ja auringon säteilyteho.

### Science Reference (Tiedeosio)
- Avaa oikean valikon kautta päästäksesi käsiksi tieteellisiin taustoihin, syvyysprofiileihin ja vertailuaineistoihin (**Validation**).

### Logic Lab (Kaavaeditori)
- Avaa Logic Lab -työkalu testataksesi ja rakentaaksesi omia biofysikaalisia yhtälöitä solmupohjaisella visuaalisella editorilla.

---

## 📱 7. Mobiilikäytön Vinkit

- **Pienet näytöt**: Vasen ja oikea sivupalkki mukautuvat automaattisesti koko ruudun laajuisiksi. Voit sulkea ne yläkulman nuolipainikkeesta.
- **Kosketusalueet**: Kaikki napit ja mikroskooppivalitsimet on optimoitu riittävän suuriksi sormella käytettäväksi.
