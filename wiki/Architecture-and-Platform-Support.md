# Arkkitehtuuri ja Teknologia (Architecture & Platform Support)

SoilScope on moderni, korkean suorituskyvyn monialustainen simulaatiosovellus, joka on rakennettu Flutter- ja Flame-teknologioiden päälle.

---

## 🏛️ Järjestelmäarkkitehtuuri

### 1. Eristetty Fysiikkasilmukka ja Isolate-suoritus
- Raskas fysiikka- ja numeerinen laskenta (Richardsin yhtälö, hiukkasfysiikka, ravinteiden advektio/diffuusio) suoritetaan taustalla erillisessä Dart **Isolatessa**.
- Pääsäie (UI thread) vastaa vain Flutter-käyttöliittymästä ja Flame-renderöinnistä, mikä takaa tasaisen 60 FPS käyttöliittymän ja vakaan 30 FPS fysiikkalaskennan.

### 2. Flame 2D -pelimoottori & Proceduraalinen Renderöinti
- Simulaatiomaailma renderöidään käyttäen Flame ECS (Entity Component System) -mallia.
- Maaprofiili, kasvin kasvu ja solutason mikroskooppinäkymät piirretään proceduraalisesti matemaattisten mallien ohjaamana.

### 3. Reaktiivinen Tilanhallinta (Riverpod)
- Sovelluksen tilanhallinta perustuu koodigeneroituun **Riverpod 2.x** -arkkitehtuuriin (`@riverpod`).
- Tilat jakautuvat selkeästi simulaatiotilaan (`simulationProvider`), istunnon tilaan (`simulationSessionProvider`) ja käyttöliittymätilaan (`uIStateProvider`).

---

## 🛠️ Alusta- ja Työkaluketjutuki

Projektin Android-työkaluketju on päivitetty vastaamaan uusimpia Google- ja Flutter-vaatimuksia:

| Työkalu / Kirjasto | Versio | Rooli |
| :--- | :--- | :--- |
| **Flutter SDK** | `3.47.6` (Channel stable) | Pääkehys ja monialustamoottori |
| **Dart SDK** | `3.13.5` | Ohjelmointikieli ja kääntäjä |
| **Gradle** | `9.1.0` | Android-rakennustyökalu (Gradle Wrapper) |
| **Android Gradle Plugin (AGP)** | `9.0.1` | Android-rakennusliitännäinen |
| **Kotlin (KGP)** | `2.3.20` | Kotlin-kääntäjä ja JVM-tuki |
| **Java / JDK** | OpenJDK 21 (LTS) | Rakennusympäristön Java-versio |

---

## 🧪 Testaus ja Laadunvarmistus

Projekti sisältää laajan automatisoidun testisarjan:
- **Biofysiikan ratkaisijat**: Hydrologia, ravinteiden kuljetus, kemia, kaasunvaihto, aggregaatio ja pistekuormat.
- **Logic Lab -evaluaattori**: Matemaattiset funktiot ja solmujen kytkennät.
- **Widget- ja UI-testit**: Jaksollinen järjestelmä, mikroskooppiohjain (HUD), työkalupalkit ja infokortit.
- **Suorituskykybenchmarkit**: `ScoringSolver`- ja hiukkaslaskentatestit.

Kaikki **75 testiä** ajetaan komennolla:
```bash
flutter test
```
Ja koodianalyysi suoritetaan komennolla:
```bash
flutter analyze
```
