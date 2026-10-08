# Nanovision Mikroskooppi (Nanovision Microscope)

**Nanovision** on SoilScopen korkean fideliteetin mikroskooppinen tarkastelutila, joka mahdollistaa kasvin, maaperän ja mikrobiston tarkastelun solutasolla. Tila yhdistää proceduraalisen 2D-renderöinnin reaaliaikaiseen biofysikaaliseen telemetriaan ja tieteellisiin yhtälöihin.

---

## 🔬 Kelluva Nanovision HUD -ohjain

Mikroskoopin aktivointi (alapalkin pikapainikkeesta, sivupalkin ohjaimista tai simulaatiomaailman kosketuspisteistä) avaa ruudulle tyylikkään, lasimorfisen HUD-ohjaimen:

- **Nopea kohdevaihto**: Yhdellä napautuksella siirtyminen 7 eri tarkastelukohteen välillä ilman sulkeutuvia valikoita.
- **Suurennosindikaattori**: Esittää kunkin kohteen optisen/digitaalisen suurennustason (200x – 1200x).
- **Interaktiivinen infonappi**: Avaa tai palauttaa opettavaisen analyysikortin (`HoverTooltip`), jos se on suljettu.
- **Sulkupainike**: Sulkee mikroskoopin ja palauttaa päänäkymän.

---

## 🌿 7 Biofysikaalista Tarkastelukohdetta

### 1. Lehti (Plant Canopy) – 400x
- **Solurakenteet**: Kutikula (cuticle), pylvässolukko (palisade mesophyll), lehtisuonet (vein) ja ilmaraot (stoma).
- **Yhtälö**: Fotosynteesin kokonaisreaktio
  $$6\text{ CO}_2 + 6\text{ H}_2\text{O} + h\nu \to \text{C}_6\text{H}_{12}\text{O}_6 + 6\text{ O}_2$$
- **Telemetria**: Turgor-paine (%), kasvin pituus (cm), LAI (lehtipinta-alaindeksi) ja transpiraatiotila.

### 2. Varsi (Stem Cross-Section) – 200x
- **Solurakenteet**: Epidermi, nila (floeemi), jälli (kambium) ja puuosa (ksyleemi).
- **Yhtälö**: Veden aksiaalinen tilavuusvirtaus putkilosoluissa
  $$J_v = L_p \cdot (\Delta\Psi_p - \sigma\Delta\Psi_s)$$
- **Telemetria**: Nestevirtaus ($\mu\text{l/s}$), turgor ja johtosolukon tila.

### 3. Kärkimeristeemi (Apical Meristem) – 800x
- **Solurakenteet**: Kasvupisteen kupu (apical dome), lehdenaiheet (primordia) ja erilaistumattomat kantasolut (stem cells).
- **Yhtälö**: Solunjakautumisen kasvudynamiikka
  $$\frac{d(\text{Cell})}{dt} = \mu \cdot N \cdot P$$
- **Telemetria**: Solukkotyyppi (meristemaattinen), erilaistumattomuus ja aktiivinen mitoosijakautuminen.

### 4. Juuri (Root Tissue) – 400x
- **Solurakenteet**: Juurikarvat (root hairs), kuorikerros (cortex), soluseinät ja Casparyn vyö (Casparian strip).
- **Yhtälö**: Juuren vesipotentiaalin gradientti suhteessa maahan
  $$\Psi_{\text{root}} = \Psi_{\text{soil}} - r_{\text{axial}} \cdot \text{Flux}$$
- **Telemetria**: Juurisolmujen lukumäärä, imuteho ja juuriston syvyys.

### 5. Ritsosfääri (Rhizosphere) – 600x
- **Solurakenteet**: Juuren pinta, eksudaatit (juurieritteet), mikrobikoloniat ja vapaat ravinteet.
- **Yhtälö**: Rhizosphere Priming Effect (eritteiden muunnos mikrobimassaksi)
  $$C_{\text{exudate}} \to \text{Biomassa} + \text{Entsyymit}$$
- **Telemetria**: Mikrobien biomassa ($\text{kg/m}^3$), biologinen aktiivisuus, pH ja redokstila.

### 6. Mikrobi (Microbial Cell) – 1200x
- **Solurakenteet**: Siimat (flagella), soluseinä, bakteeri-DNA ja ekstrasellulaariset entsyymit.
- **Yhtälö**: Soluhengitys ja energian tuotanto
  $$\text{C}_6\text{H}_{12}\text{O}_6 + 6\text{ O}_2 \to 6\text{ CO}_2 + 6\text{ H}_2\text{O} + \text{ATP}$$
- **Telemetria**: $\text{CO}_2$-pitoisuus ($\text{mol/m}^3$), aineenvaihdunnan tila ja maan lämpötila (K).

### 7. Maan Rakenne (Soil Structure) – 250x
- **Solurakenteet**: Murenat (aggregates), hiekkajyväset, savilamellit (clay platelets), halkeamat ja huokoisuus.
- **Yhtälö**: Murenarakenteen stabiliteettiyhtälö
  $$\text{Stability} = f(\text{EPS}, \text{Clay}, \text{Fungal\_Hyphae})$$
- **Telemetria**: Aggregaattien vakaus (%), savijaeprosentti ja huokoisuus (porosity).

---

## 🌐 Lokalisointi ja Kaksikielisyys

Kaikki mikroskoopin solumerkinnät, otsikot, tilatekstit ja opettavaiset kuvaukset on lokalisoitu täysin suomeksi (`app_fi.arb`) ja englanniksi (`app_en.arb`).
