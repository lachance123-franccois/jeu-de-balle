# 🎱 Balles Rebondissantes + Analyse FFT

> Simulation physique de balles rebondissantes couplée à une analyse spectrale complète — projet pédagogique Master SIA, Traitement du Signal.

![MATLAB](https://img.shields.io/badge/MATLAB-R2020b%2B-orange?style=flat-square)
![Toolbox](https://img.shields.io/badge/Toolbox-Aucune%20requise-green?style=flat-square)
![Licence](https://img.shields.io/badge/Licence-MIT-blue?style=flat-square)

---

## 📌 Description

Ce projet fait le lien entre **simulation physique** et **traitement du signal numérique**.  
Des balles rebondissent dans une boîte sous l'effet de la gravité et des frottements — leurs positions verticales sont enregistrées comme signaux discrets, puis analysées par FFT.

L'objectif est pédagogique : illustrer concrètement les concepts du cours de traitement du signal à travers un signal physique simple et visuel.

---

## 🧠 Concepts illustrés

| Concept | Description |
|---|---|
| Signal discret `x(n)` | Position verticale de chaque balle échantillonnée à Fe = 200 Hz |
| **FFT** | Transformée de Fourier Discrète rapide — `X(k) = Σ x(n)·e^{-j2πkn/N}` |
| Spectre d'amplitude | `\|X(f)\|` — identification de la fréquence fondamentale de rebond |
| **DSP** | Densité Spectrale de Puissance — `PSD(f) = \|X(f)\|² / N` (en dB) |
| **Spectrogramme STFT** | Évolution temporelle du spectre — `X(τ,f) = Σ x(n)·w(n-τ)·e^{-j2πfn}` |
| Fenêtrage | Comparaison Hann / Hamming / Rectangulaire — effet sur la fuite spectrale |
| Fréquence de Nyquist | `Fn = Fe/2 = 100 Hz` |
| Résolution fréquentielle | `Δf = Fe/N = 0.1 Hz` |

---

## 🚀 Utilisation

```matlab
% Lancer avec les paramètres par défaut (3 balles, restitution 0.85)
balles_fft

% Personnaliser
balle_rebondissante_fft(5, 0.90)   % 5 balles, restitution 0.90
balle_rebondissante_fft(1, 1.00)   % 1 balle, rebond parfait
```

### Via le menu interactif
```matlab
demo_balles
```

---

## 📊 Sorties générées

Le programme produit une figure 3×4 avec :

1. **Signal temporel** `y(t)` — position verticale de chaque balle
2. **Centrage + fenêtrage Hann** — prétraitement avant FFT
3. **Spectre d'amplitude** `|X(f)|` — avec marquage des fréquences fondamentales
4. **DSP en dB** — densité spectrale de puissance
5. **Spectrogramme STFT** — évolution fréquentielle au cours du temps
6. **Comparaison de fenêtrages** — fuite spectrale Rect. vs Hann vs Hamming
7. **Spectre de phase** `∠X(f)`

---

## ⚙️ Paramètres physiques

| Paramètre | Valeur | Description |
|---|---|---|
| `Fe` | 200 Hz | Fréquence d'échantillonnage (`dt = 0.005 s`) |
| `T_sim` | 10 s | Durée de simulation |
| `N` | 2000 | Nombre d'échantillons |
| `g` | 9.81 m/s² | Gravité |
| `drag` | 0.9995 | Coefficient de frottement de l'air |
| `restitution` | 0.85 | Coefficient de restitution au rebond |

---

## 🔭 Perspectives d'application

> Ces pistes n'ont pas encore été implémentées — elles constituent des directions d'extension possibles.

- **Biomécanique** — analyse du rebond d'une prothèse ou de la foulée d'un coureur via capteurs inertiels
- **Génie civil** — détection de fréquences de vibration anormales dans des structures (ponts, bâtiments)
- **Acoustique** — modélisation de la propagation d'ondes par analogie avec les collisions
- **Maintenance prédictive** — détection d'anomalies dans des signaux périodiques amortis
- **Simulation de matériaux** — comportement dynamique sous impact répété

---
## 🛠️ Prérequis

- MATLAB R2020b ou supérieur
- **Aucune toolbox requise** (pas de Signal Processing Toolbox)

---

## 👤 Auteur

Projet réalisé dans le cadre du Master SIA — cours de Traitement du Signal.