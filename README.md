# SoilScope - Soil-Plant-Atmosphere Simulator

SoilScope on tieteellisesti tarkka maaperä-kasvi-ilmakehä-jatkumon (SPAC) simulaattori, joka yhdistää pelillistetyn oppimisen ja laskennallisen ekofysiologian. Sovellus on kehitetty osana puutarhatalouden hortonomin (AMK) opinnäytetyötä, Agentic Coding-menetelmin.

---

## ✅ Toteutetut Ominaisuudet

### 🌊 Hydrologia & Fysiikka
- **1D Richards-yhtälö** numeerisella ratkaisijalla
- **Van Genuchten-Mualem** maahydrauliikka
- **Hystereesi** (kuivatus/kostutus)
- **Bypass Flow** dynaamisesti kytkettyjen lierojen makrohuokosten kautta
- **Kapillaarinen nousu** kuivumisnäkymässä
- **Dynaaminen auringonsäteily**: Kytketty fotosynteesiin reaaliaikaisella PAR-muunnoksella (W/m² → µmol m⁻² s⁻¹)

### 🌱 Kasvin Fysiologia (SPAC)
- **Farquhar-von Caemmerer-Berry (FvCB)** C3-fotosynteesimalli
- **Tardieu ilmarakomalli** stomataaliselle konduktanssille
- **Jarvis kompensoiva vedenotto** - kuivat kerrokset kompensoivat
- **C-ROOT** dynaaminen juuriarkkitehtuuri gravotropismilla (pääjuuret kasvavat pystysuoraan alaspäin)
- **Synkronoitu usean kasvin SPAC-jatkumo**: Animaatiot ja ratkaisijat tukevat useita kasveja samanaikaisesti, versot ja juuret on ankkuroitu täsmälleen samaan pisteeseen.
- **Orgaaninen kasvikomponentti**: Proceduraalinen `CustomPainter`-pohjainen kasvi, joka visualisoi verson ja juuriston kasvua dynaamisesti.
- **Hiilen hallinta (POM/MAOM)**: Dynaaminen labiilin ja stabiilin hiilen säätely, Rhizosphere Priming Effect -ketjun aktivointi ja hiukkasfysiikan Q10-vaste.
- **Dynaaminen virtausseuranta**: ravinteet ja vesi hakeutuvat todellisiin juurenpäihin

### 🧪 Biogeokemia
- **Rhizosphere Priming Effect**: juurieritteet aktivoivat mikrobit kausaalisessa ketjussa
- **TEA Redox-tikapuut**: O₂ → NO₃⁻ → MnO₂ → Fe(III) → SO₄²⁻ → CH₄
- **Tieteellinen Redox-kalibrointi**: Päivitetyt kynnysarvot `chemistry_solver.dart`:ssa ja Nernst-yhtälön laskenta
- **Michaelis-Menten entsyymikinetiikka** (urease, phosphatase, cellulase, protease)
- **Mykorritsasymbioosi** dynaaminen verkosto ja C-P-N vaihto
- **Energiatehokas Kemotaksis (Vähimmän Energian Periaate)**: Kaikki organismit (juuret, sienirihmastot ja mikrobit) hakeutuvat resursseihin energiatehokkaasti (Fickin laki & Cost-Benefit).
- **Symbioottinen Louhinta**: Orgaanisen fosforin ja typen muokkaus liukoiseksi Michaelis-Menten -kinetiikalla.
- **C/N Immobilisaatio**: Mikrobit sitovat typpeä, kun C/N-suhde > 25.
- **Tillage-muokkaushäiriöt**: Maan muokkaus rikkoo sienirihmastoverkoston (80% vähennys).
- **POM/MAOM hiilimalli** (Microbial Carbon Pump)
- **Typen kierto** (DNDC): nitrifikaatio, denitrifikaatio, immobilisaatio "morphing"-animaatioilla
- **Sähköstaattinen fysiikka**: Coulombin laki ohjaa ionien hakeutumista varautuneille pinnoille

### 🎮 Interaktiivinen Hallintapaneeli & Digital Twin
- **Eristetty HUD-kerros (Viewport)**: Kamerasta riippumaton kiinteä käyttöliittymäkerros. Yhdistetyt `LayerHUDPanel` -blokit oikeassa reunassa ja `SoilTextureTriangle` -säätimet vasemmassa reunassa dynaamisella pystysuuntaisella asettelulla.
- **Nanovision (Mikroskooppi)**: Palautettu mikroskooppiominaisuus, joka mahdollistaa yksityiskohtaisen poikkileikkausnäkymän juurista, lehdistä ja mikrobeista.
- **3-Kerroksinen UI**: visualisointi keskittyy biologisesti aktiiviseen pintamaahan (Top 50cm)
- **Atmosfäärin ohjaus**: Kaasunvaihdon ($CO_2$, $H_2O$) dynaamiset animaatiot synkronoitu kunkin kasvin lehvästön sijaintiin.
- **Tieteelliset kaaviot**: Mollier-diagrammi ja PAR-näkymä Control Panelissa tarkempaan atmosfäärin analyysiin.
- **Puhdas visuaalisuus**: teksti on poistettu animaatiosta ja korvattu tieteellisillä symboleilla ja CPK-standardeilla
- **Isolate-pohjainen fysiikka (30 FPS)**: tuhansien hiukkasten dynaaminen laskenta on optimoitu tasaiseen 30 FPS tahtiin.
- **LOD (Level of Detail)**: hiukkasrenderöinti skaalautuu zoom-tason mukaan suorituskyvyn varmistamiseksi
- **Full-Screen Immersive Digital Twin**: Simulaatio täyttää nyt koko ruudun dynaamisesti säätyvällä horisontilla ja ilmakehällä, poistaen aiemman "laatikkomaisen" rajoitteen.
- **Flutter Overlay Inspector**: Korkean fideliteetin bioväylätietojen tarkastelu on toteutettu dynaamisena Flutter-kerroksena, joka mahdollistaa lasimaisen (glassmorphism) käyttöliittymän ja paremman luettavuuden.
- **SPAC-kausaalisuusnuolet**: Kaasunvaihdon ja veden virtauksen animaatiot sisältävät nyt suuntanuolet ja realiaikaisen voimakkuussäädön, jotka visualisoivat biovirtauksia.
- **Natiivit Pikatoiminnot (Quick Actions)**: Korvattu aiempi Flame-pohjainen toimintapalkki dynaamisilla ja responsiivisilla Flutter-widgeteillä, jotka sisältävät täydelliset työkaluvihjeet (tooltips) ja paremman käytettävyyden.
- **Typenkierron havainnointitila**: Mahdollistaa N-yhdisteiden ($NH_4^+$, $NO_3^-$) korostamisen ja muiden himmentämisen `FlutterQuickActions`-paneelista.
- **Tilan tallennus & Toisto**: Integroitu `SharedPreferences`-pohjainen tilan tallennus ja aikajanan toistonäppäimet.
- **Dynaaminen Skenaarioeditori (Scenario Builder)**: Luo omia skenaarioita säätämällä maalajeja, alkukosteutta ja viljelysuunnitelmia (lannoitus, kastelu, muokkaus).


### 🧮 Logic Lab - Visuaalinen biofysiikan editori
- **Node-pohjainen graafieditori** tieteellisten kaavojen tarkasteluun ja dynaamiseen testaamiseen.
- **Tuetut funktiot ja matemaattinen pohja:**
  - **Q10 (Lämpötilakerroin):** $f(T) = Q_{10}^{((T - 20) / 10)}$
  - **Michaelis-Menten (Entsyymikinetiikka):** $v = V_{max} \cdot \frac{[S]}{(K_m + [S])}$
  - **van Genuchten (Vedenpidätys):** $\theta(h) = \theta_r + \frac{\theta_s - \theta_r}{[1 + |\alpha h|^n]^m}$
  - **Farquhar-von Caemmerer-Berry (FvCB):** $A_c = V_{cmax} \cdot \frac{C_i - \Gamma^*}{C_i + K_c(1 + O/K_o)}$
  - **Nernst-yhtälö (Redox):** $pe = pe_0 - \frac{1}{n} \cdot \log_{10}\frac{[red]}{[ox]}$
  - **Chemotaxis (Fickin laki):** $J = -D \cdot \frac{C_2 - C_1}{dx}$
  - **Cost-Benefit (Vähimmän energian periaate):** $A = \frac{C}{D + P}$
- **Live-evaluointi** simulaatiodatalla
- **UX-parannukset**: Työkaluvihjeet (Tooltips) ja reaaliaikainen yksiköiden muotoilu solmuille.

### 🔬 Validointi & Diagnostiikka
- **Tilastolliset metriikat**: RMSE, NSE, R², MAE
- **Kytkentämatriisi** järjestelmädiagnostiikkaan
- **Science Validation Tab**: Reaaliaikainen tilastollisten mittareiden (RMSE, NSE, R²) seuranta käyttöliittymässä.
- **50 yksikkötestiä** biofysiikan solvereiden varmistamiseen

---

## 🚀 Käynnistys

```bash
# Asenna riippuvuudet
flutter pub get

# Generoi Freezed-koodi
dart run build_runner build --delete-conflicting-outputs

# Käynnistä sovellus
flutter run
```

---
## Hankkeen tila: Minimum Debatable Product (MDP)

Soilscope (MFCKT-arkkitehtuuri) on tällä hetkellä **Minimum Debatable Product (MDP)** -vaiheessa. Koska hanke on kehittynyt osana konstruktiivista tutkimusta (Constructive Research Approach), tavoitteena ei ole julkaista suljettua, "valmista" kaupallista tuotetta, vaan tarjota yhteinen, interaktiivinen alusta (Common Ground) maaperätieteilijöiden, kasvifysiologien ja ohjelmistokehittäjien väliselle tieteelliselle debatille. 

Olemme tarkoituksella rajanneet simulaation ensimmäisen julkaisun ydinominaisuudet kapeiksi, jotta voimme validoida perustan ennen monimutkaisuuden lisäämistä.

### MVP-ydin: Typen kierto ja SPAC-jatkumo
Tällä hetkellä simulaatiomoottorin ehdoton painopiste on typen kierrossa osana SPAC-jatkumoa (Soil-Plant-Atmosphere Continuum). Moottori mallintaa dynaamisesti orgaanisen aineksen mineralisaatiota, C:N-suhteeseen perustuvaa immobilisaatiota sekä kasvin juuriston kemotaksista ja ravinteiden massavirtaa. Muut ekosysteemin muuttujat (kuten laajemmat ilmakehän kaasujen vaihdot) on toistaiseksi vaimennettu tai yksinkertaistettu, jotta typenkierron visuaalinen ja matemaattinen validointi voidaan suorittaa häiriöttömästi.

### Arkkitehtuurin tulevaisuus: Dart-käyttöliittymästä Go-taustajärjestelmään
Tällä hetkellä simulaatio on rakennettu puhtaasti Dartilla, hyödyntäen Flame-fysiikkamoottoria visualisointiin ja Riverpodia tilanhallintaan. Tämä mahdollistaa äärimmäisen responsiivisen käyttöliittymän selaimessa ja mobiilissa. 

**Tulevaisuuden tiekartta:** Kun mikrobipopulaatioiden ja biokemiallisten yhtälöiden kompleksisuus kasvaa, Riverpodin laskentakapasiteetti selaimessa tulee vastaan. Seuraavan vaiheen arkkitehtuurissa raskaampi biogeokemiallinen ratkaisija (biophysical solver) ja massadatan prosessointi on tarkoitus siirtää korkean suorituskyvyn **Go-kielellä** kirjoitetulle taustajärjestelmälle. Tällöin Dart/Flame-frontend jää puhtaasti kevyeksi visualisointikerrokseksi ("dumb visualizer"), joka lukee tilapäivityksiä Go-moottorilta. Etsimme aktiivisesti yhteistyökumppaneita tämän rajapinnan suunnitteluun.

### 🐛 Tiedossa olevat rajoitteet ja tieteelliset haasteet (Known Issues)
Seuraavat osa-alueet vaativat vielä tutkimuksellista validointia ja kooditason kontribuutioita:

* **pH:n dynaaminen palaute:** Mineralisaation ja nitrifikaation kinetiikka on toistaiseksi yksinkertaistettu. Lokaalin pH-arvon muutosten vaikutusta entsyymiaktiivisuuteen ei vielä lasketa dynaamisesti takaisinkytkentänä.
* **Visuaaliset rajoitteet vs. Biologinen todellisuus:** Suorituskykysyistä (vältääksemme Flame-moottorin GC-kuormitusta ja renderöinnin hidastumista) mikrobiklustereiden ja ravinnehiukkasten maksimimäärät on tällä hetkellä kovakoodattu. Tämä abstrahoi visuaalisesti biomassan todellisen mittakaavan.
* **Denitrifikaation reunaehdot:** Veden kyllästämän huokostilavuuden (WFPS) kynnysarvot ja niiden suora korrelaatio typen kaasumaiseen hävikkiin ($N_2$, $N_2O$) vaativat hienosäätöä asiantuntijoiden datasettien pohjalta.
* **Kosteusprofiili ja kapillaarisuus:** Maaperän kosteutta käsitellään toistaiseksi liian homogeenisesti; kapillaarisen nousun fysiikka savimaissa puuttuu vielä mallista.

Otamme mielellämme vastaan Pull Requesteja – koskivat ne sitten Dart-koodin optimointia tai fysiologisten kaavojen korjaamista!

---

## 📄 Lisenssi

Tämä projekti on lisensoitu avoimen lähdekoodin **MIT** -lisenssillä.

Katso täydet ehdot tiedostosta [LICENSE.md](LICENSE.md).

### Käytetyt kirjastot ja niiden lisenssit

| Kirjasto | Käyttötarkoitus | Lisenssi |
| :--- | :--- | :--- |
| **Flutter SDK** | Käyttöliittymäkehys | BSD-3-Clause |
| **Flame** | 2D-pelimoottori ja animaatiot | MIT |
| **Flutter Riverpod** | Reaktiivinen tilanhallinta | MIT |
| **Equations** | Matemaattiset ratkaisijat | MIT |
| **Oxygen** | Kevyt ECS-fysiikkamoottori | MIT |
| **Flutter SVG** | Vektorigrafiikan renderöinti | MIT |
| **Freezed** | Immuuttomat datamallit | MIT |
| **Intl** | Kansainvälistyminen ja lokalisointi | BSD-3-Clause |
| **Shared Preferences** | Paikallinen asetusten tallennus | BSD-3-Clause |
| **Flutter Secure Storage** | Suojattu avainten tallennus | BSD-3-Clause |
| **JSON Annotation** | JSON-serialisointi | BSD-3-Clause |


