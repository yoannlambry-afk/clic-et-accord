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

Le Mac a déjà le certificat de développement et l'équipe (réglée dans le projet). iPhone branché et déverrouillé :

```bash
xcodebuild -project ios/App/App.xcodeproj -scheme App -configuration Debug \
  -destination 'generic/platform=iOS' -derivedDataPath ios/App/DerivedData -allowProvisioningUpdates build
xcrun devicectl list devices
xcrun devicectl device install app --device <identifiant de l'iPhone> ios/App/DerivedData/Build/Products/Debug-iphoneos/App.app
```

Avec un identifiant Apple gratuit, l'appli expire au bout de 7 jours : il suffit de la réinstaller. Avec un compte développeur payant (99 €/an), elle reste installée un an et peut être distribuée via TestFlight.

## Mettre à jour

Toute modification se fait dans `docs/index.html`.

- Web : `git commit` puis `git push`, GitHub Pages redéploie en une minute.
- iPhone : `npx cap copy ios` puis les commandes d'installation ci-dessus.
