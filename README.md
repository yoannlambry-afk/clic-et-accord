# bibeO · Clic & Accord

Accordeur guitare, métronome et setlist du groupe bibeO.

- **Version web** (https, utilisable sur n'importe quel téléphone) : https://yoannlambry-afk.github.io/clic-et-accord/
- **Appli iPhone** : même interface, mais le clic est joué par iOS et continue écran verrouillé.

## Organisation

- `docs/` : l'application web complète (`index.html`), servie par GitHub Pages et embarquée dans l'appli.
- `ios/App/` : projet Xcode généré par Capacitor.
  - `App/MetroPlayerPlugin.swift` : lecteur natif du métronome (AVAudioPlayer en boucle, session audio en arrière-plan).
  - `App/MainViewController.swift` : enregistre ce plugin au démarrage.

## Installer l'appli sur un iPhone

1. Ouvrir le projet : `open ios/App/App.xcodeproj`
2. Dans Xcode, menu **Xcode › Settings › Accounts** : ajouter son identifiant Apple si ce n'est pas déjà fait.
3. Sélectionner la cible **App**, onglet **Signing & Capabilities** : cocher *Automatically manage signing* et choisir son équipe (son identifiant Apple).
4. Brancher l'iPhone, le choisir en haut de la fenêtre comme destination, puis **Run** (▶).
5. Sur l'iPhone, la première fois : **Réglages › Général › VPN et gestion de l'appareil**, faire confiance au développeur.

Avec un identifiant Apple gratuit, l'appli expire au bout de 7 jours : il suffit de refaire un Run depuis Xcode. Avec un compte développeur payant (99 €/an), elle reste installée un an et peut être distribuée via TestFlight.

## Mettre à jour

Toute modification se fait dans `docs/index.html`.

- Web : `git commit` puis `git push`, GitHub Pages redéploie en une minute.
- iPhone : `npx cap copy ios` puis Run dans Xcode.
