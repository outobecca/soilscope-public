# Logic Lab - Visuaalinen Biofysiikan Editori

**Logic Lab** on SoilScopen visuaalinen solmupohjainen graafieditori, joka mahdollistaa biofysiikan yhtälöiden tutkimisen, yhdistämisen ja reaaliaikaisen testaamisen simulaatiodatalla.

---

## 🧩 Solmutyypit (Node Categories)

Logic Labissa solmut jaetaan neljään pääluokkaan:

1. **Syötesolmut (Inputs)**
   - Lukevat reaaliaikaisia arvoja simulaatiotilasta (esim. maan lämpötila, kosteus $\theta$, redokspotentiaali $Eh$, valon määrä PAR, stomataalinen konduktanssi).
2. **Biofysikaaliset funktiosolmut (Biophysical Functions)**
   - Sisältävät tieteelliset laskentakaavat (Q10, Michaelis-Menten, Farquhar FvCB, van Genuchten, Nernst, Fickin diffuusiolaki, Cost-Benefit).
3. **Matemaattiset operaatiot (Math Operations)**
   - Yhteen-, vähennys-, kerto- ja jakolaskut, potenssit, logaritmit ja minimi/maksimi-valitsimet.
4. **Tulossolmut (Outputs & Telemetry)**
   - Esittävät lasketun tuloksen graafisesti ja numeerisesti yksiköineen.

---

## 📐 Tuetut Funktiot

- **Q10-lämpötilakerroin**: $f(T) = Q_{10}^{((T - 20) / 10)}$
- **Michaelis-Menten**: $v = V_{\max} \cdot \frac{[S]}{(K_m + [S])}$
- **van Genuchten**: $\theta(h) = \theta_r + \frac{\theta_s - \theta_r}{[1 + |\alpha h|^n]^m}$
- **Farquhar FvCB**: $A_c = V_{c\max} \cdot \frac{C_i - \Gamma^*}{C_i + K_c(1 + O/K_o)}$
- **Nernst (Redox)**: $pe = pe_0 - \frac{1}{n} \cdot \log_{10}\frac{[\text{red}]}{[\text{ox}]}$
- **Kemotaksis (Fickin laki)**: $J = -D \cdot \frac{C_2 - C_1}{dx}$
- **Cost-Benefit (Vähimmän energian periaate)**: $A = \frac{C}{D + P}$

---

## 🧪 Käyttötapaukset Opetuksessa ja Tutkimuksessa

- **Hypoteesien testaaminen**: Käyttäjä voi muuttaa funktion parametreja (esim. $Q_{10}$-kerrointa tai $K_m$-arvoa) ja havaita välittömästi reaktionopeuden muutoksen.
- **Kytkentöjen ymmärtäminen**: Graafi havainnollistaa suoraan, miten ympäristömuuttujat (kuten lämpötilan nousu tai maan kuivuminen) etenevät ketjussa entsyymiaktiivisuuteen ja kasvin kasvuun.
