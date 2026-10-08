# Biofysikaalinen Simulaatiomalli (SPAC & Biophysics)

SoilScopen simulaatio perustuu vakiintuneisiin fysikaalisiin, biologisiin ja kemiallisiin malleihin maaperä-kasvi-ilmakehä-jatkumossa (SPAC).

---

## 🌊 1. Hydrologia ja Maaperäfysiikka

### 1D Richardsin yhtälö
Veden virtaus huokoisessa maassa ratkaistaan 1D Richardsin yhtälöllä:

$$\frac{\partial \theta}{\partial t} = \frac{\partial}{\partial z} \left[ K(\psi) \left( \frac{\partial \psi}{\partial z} + 1 \right) \right] - S(z, t)$$

missä:
- $\theta$: Maan tilavuuskosteus ($\text{m}^3/\text{m}^3$)
- $\psi$: Matriisipotentiaali ($\text{m}$)
- $K(\psi)$: Hydraulinen johtavuus ($\text{m/s}$)
- $S(z, t)$: Juuriston vedenottotermi (Sink term)

### Van Genuchten-Mualem -malli
Maan vedenpidätyskäyrä ja johtavuus lasketaan yhtälöillä:

$$\Theta = \frac{\theta - \theta_r}{\theta_s - \theta_r} = \left[ 1 + |\alpha h|^n \right]^{-m}$$

$$K(\Theta) = K_s \Theta^l \left[ 1 - (1 - \Theta^{1/m})^m \right]^2$$

missä $m = 1 - 1/n$.

---

## 🌱 2. Kasvifysiologia

### Farquhar-von Caemmerer-Berry (FvCB) Fotosynteesimalli
C3-kasvien nettofotosynteesi $A$ määräytyy Rubisco-rajoitteisen ($A_c$) ja elektroninsiirtorajoitteisen ($A_j$) nopeuden miniminä:

$$A = \min(A_c, A_j) - R_d$$

$$A_c = V_{c\max} \frac{C_i - \Gamma^*}{C_i + K_c (1 + O / K_o)}$$

### Tardieu-Davies Stomatamalli
Ilmarakojen johtavuus $g_s$ reagoi lehtien vesipotentiaaliin ja ilman höyrynpainealijäämään (VPD):

$$g_s = g_0 + \frac{a \cdot A}{(C_s - \Gamma) (1 + \text{VPD} / D_0)}$$

---

## 🧪 3. Biogeokemia ja Redox-dynamiikka

### TEA Redox-tikapuut (Terminal Electron Acceptor)
Hapettomissa olosuhteissa mikrobit käyttävät vaihtoehtoisia elektronin vastaanottajia standardipotentiaalien järjestyksessä:
1. **Aerobinen hengitys**: $\text{O}_2 \to \text{H}_2\text{O}$ ($Eh > +300\text{ mV}$)
2. **Denitrifikaatio**: $\text{NO}_3^- \to \text{N}_2\text{O} / \text{N}_2$ ($+100 \dots +300\text{ mV}$)
3. **Mangaani- ja rautareduktio**: $\text{Mn}^{4+} \to \text{Mn}^{2+}$, $\text{Fe}^{3+} \to \text{Fe}^{2+}$
4. **Sulfaattireduktio**: $\text{SO}_4^{2-} \to \text{H}_2\text{S}$ ($-150 \dots 0\text{ mV}$)
5. **Metanogeneesi**: $\text{CO}_2 \to \text{CH}_4$ ($Eh < -200\text{ mV}$)

### Nernst-yhtälö
Redox-potentiaali lasketaan Nernst-yhtälön mukaisesti:

$$Eh = E^0 + \frac{RT}{nF} \ln \left( \frac{[\text{Ox}]}{[\text{Red}]} \right)$$

---

## 🦠 4. Mikrobiologinen Kinetiikka ja Typen Kierto

### Michaelis-Menten Kinetiikka
Entsyymireaktiot (ureaasi, fosfataasi, sellulaasi) mallinnetaan Michaelis-Menten -kinetiikalla:

$$v = V_{\max} \frac{[S]}{K_m + [S]}$$

### Q10 Lämpötilariippuvuus
Mikrobien aktiivisuus skaalautuu lämpötilan mukaan:

$$f(T) = Q_{10}^{\frac{T - T_{\text{ref}}}{10}}$$
