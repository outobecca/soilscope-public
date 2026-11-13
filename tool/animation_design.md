Animaatioarkkitehtuuri ja Visuaaliset Säännöt (design.md)
Tämä dokumentti määrittelee ehdottomat säännöt Flame-moottorin ja Dart-koodin visuaaliselle toteutukselle MFCKT-sovelluksessa. Näitä sääntöjä ei saa ohittaa missään olosuhteissa.

1. Yleiset Periaatteet (Core Principles)
Separation of Concerns: Flame-moottori on vain tyhmä visualisoija. Se ei koskaan päätä simulaation säännöistä. Kaikki matemaattinen tila (State), aineen määrä ja aineenvaihduntalogiikka asuvat Riverpod-providereissa.

Massasäilymislaki: Järjestelmä ei saa luoda ravinteita (esim. typpi, kalium) tyhjästä. Jokainen kankaalle generoituva partikkeli on oltava sidoksissa Riverpodin tilaan (varaston väheneminen -> partikkelin synty).

CPK-Standardi: Kaikki molekyylit ja ravinteet renderöidään tieteellisen CPK-väristandardin mukaisesti. Värikoodausta ei saa muuttaa visuaalisen ilmeen vuoksi.

2. Komponenttien Elinkaari (Lifecycle & Memory)
Kaikkien liikkuvien partikkelien (vesi, ravinteet, eritteet) on noudatettava tiukkaa elinkaarta, jotta renderöintipuskuri ei tukkeudu (Zero Zombie Particles -sääntö).

Spawn (Synty): Partikkeli lisätään kankaalle (world.add) vain, jos Object Pool tai maksimiraja (esim. max 100 partikkelia) sallii sen.

Move (Liike): Liikevektori (Velocity) päivitetään update(double dt) -metodissa. Vältä dynaamisia Map-allokaatioita tai raskaita objektien luonteja update-luupin sisällä. Käytä kiinteitä puskureita (esim. Float64List).

Arrive & Consume (Saapuminen ja Tuhoaminen): Kun partikkeli saavuttaa tavoitekoordinaattinsa (esim. juuren pinnan hitboksin), seuraavien kolmen asian on tapahduttava synkronoidusti:

Kutsu removeFromParent() (Poistaa partikkelin Flame-puusta).

Lähetä päivitys Riverpodille (ref.read(provider.notifier).absorb(...)).

Pura kaikki Flame-kuuntelijat (StreamSubscription.cancel()) onRemove-metodissa muistivuotojen estämiseksi.

3. Renderöintijärjestys (Z-Index / Priority Strict Hierarchy)
Käyttöliittymä ei saa koskaan peittyä fysiikan alle, eikä juuristo saa peittää maaperän dataa. Komponenttien priority on lukittu seuraavasti:

priority = 0: Maaperän tausta (Background)

priority = 10: Maaperän rakenteet ja aggregaatit

priority = 20: Hotspot-ikonit (Tila: Suljettu/Passiivinen)

priority = 30: Mykoritsarihmasto ja bakteeriklustereiden alustat

priority = 50: Kasvin juuristo (pääjuuri ja sivujuuret)

priority = 60: Liikkuvat ravinne- ja vesipartikkelit

priority = 70: Kasvin varsi ja lehdet

priority = 100+: UI HUD, Työkaluvihjeet ja laajennetut Hotspotit (Nämä ovat ohittamattomia).

4. Animaatioiden Erityisvaatimukset (Animation Flows)
4.1 Typen massavirta (Nitrogen Cycle - MVP)
Visuaalinen tyyli: Typpipartikkelit liikkuvat selkeänä, loogisena jonona. Ei satunnaista välkkymistä.

Reitti: Maaperän Orgaaninen Aines (POM) -> Mineralisaatio -> Bezier-käyrää pitkin kohti lähintä juurta -> Sisään juureen -> Ksyleemiä pitkin varteen.

Kiellettyä: Typpipartikkelit eivät saa jämähtää lehdille tai juuriin staattisesti. Niiden on sulauduttava kasvin biomassaan ja poistuttava kankaalta välittömästi.

4.2 Symbioottinen Verkosto (Mycorrhiza & Hotspots)
Sijoittelu: Hotspotit on ripoteltava maaperään Poisson Disk -tyyppisellä tai minimietäisyyttä (threshold) kunnioittavalla logiikalla. Ne eivät saa syntyä päällekkäin.

Kasvu: Mykoritsarihmasto (Mycelium) generoidaan AINA kasvin juuresta käsin kohti hotspotia. Se ei saa ilmestyä tyhjään tilaan.

Mikrobikohdistus: Mikrobit ankkuroidaan fyysisesti hotspottien ympärille. Irrallisia mikrobeja saa leijailla kankaalla maksimissaan 20% kokonaismäärästä; loput 80% on kiinnitetty klustereihin.

4.3 Ilmakehän Dynamiikka
Liike: Ilmakehän hiukkaset (hiilidioksidi, happi) eivät saa liikkua viivasuoria "putkia" pitkin. Niiden liikevektoriin on koodattava kevyt x-akselin driftaus (tuuli) ja satunnaiskävely (kohina), jotta tila näyttää fluidilta dynamiikalta.

5. Kielletyt Toimenpiteet (DO NOT DO THIS)
Älä koskaan aktivoi debugMode = true tuotantokoodissa (aiheuttaa laatikoita ruudulle).

Älä koskaan käytä sumennus- tai hehkuefektejä (blur/glow) suurella opasiteetilla, jos ne peittävät alleen interaktiivista tai informatiivista dataa (esim. ritsosfäärin valo saa olla max opacity: 0.15).

Älä koskaan typistä koodia (esim. // rest of the code here), kun päivität komponentteja tämän dokumentin perusteella.
