# SoilScope Wiki

Tervetuloa **SoilScope** (Soil-Plant-Atmosphere Continuum Simulator) -hankkeen viralliseen wikiin!

SoilScope on tieteellisesti kalibroitu, biofysiikkaan ja laskennalliseen ekofysiologiaan perustuva digitaalinen kaksonen (Digital Twin) ja oppimisalusta. Hanke yhdistää maaperätieteen, kasvifysiologian ja interaktiivisen simulaation modernilla Flutter- ja Flame-teknologialla.

---

## 📚 Wikin Sisällysluettelo

1. [**Nanovision Mikroskooppi (Nanovision Microscope)**](Nanovision-Microscope.md)
   - 7 biofysikaalista tarkastelukohdetta (Lehti, Varsi, Kärkimeristeemi, Juuri, Ritsosfääri, Mikrobi, Maan rakenne)
   - Kelluva lasimorfinen Nanovision HUD -ohjain
   - Suurennoskertoimet (200x – 1200x) ja reaaliaikainen telemetria
   - Matemaattiset ja biokemialliset yhtälöt solutasolla

2. [**Alkuaineiden Valinta ja Ravinteiden Hallinta (Nutrient System)**](Element-Selection-and-Nutrients.md)
   - Interaktiivinen ja responsiivinen Jaksollinen Järjestelmä (`ElementSelectionModal`)
   - Tärkeimpien kasviravinteiden pikavalitsimet (`FlutterQuickActions`)
   - CPK-standardin mukainen värijärjestelmä
   - Opetukselliset infokortit ja biologiset puutosoireet

3. [**Biofysikaalinen Simulaatiomalli (SPAC & Biophysics)**](SPAC-Simulation-and-Biophysics.md)
   - 1D Richardsin yhtälö ja van Genuchten -hydrauliikka
   - Farquhar-von Caemmerer-Berry (FvCB) fotosynteesi ja Tardieu-stomatamalli
   - Redox-tikapuut ja Nernst-yhtälö
   - Michaelis-Menten entsyymikinetiikka ja typen kierto (DNDC)

4. [**Logic Lab - Visuaalinen Kaavaeditori**](Logic-Lab.md)
   - Node-pohjainen graafieditori
   - Tuetut matemaattiset ja biofysikaaliset funktiot
   - Reaaliaikainen evaluointi simulaatiotilasta

5. [**Arkkitehtuuri ja Teknologia (Architecture & Tech Stack)**](Architecture-and-Platform-Support.md)
   - Flutter 3.47+ & Flame ECS -arkkitehtuuri
   - Reaktiivinen tilanhallinta (Riverpod) ja Isolate-fysiikka
   - Android-alustan modernisointi (Gradle 9.1.0, AGP 9.0.1, Kotlin 2.3.20)
   - Laadunvarmistus ja testaus (75 automatisoitua testiä)

---

## 🎯 Hankkeen Tausta ja Tavoite

SoilScope on kehitetty osana puutarhatalouden hortonomin (AMK) opinnäytetyötä käyttäen Agentic Coding -menetelmää. Projektin filosofiana on **Minimum Debatable Product (MDP)**: tarjota tutkijoille, opiskelijoille ja alan ammattilaisille yhteinen interaktiivinen alusta, jossa biofysikaalisia teorioita ja niiden vuorovaikutuksia voidaan testata, visualisoida ja debatoida havainnollisesti.
