<p align="center">
  <img src="./assets/icon.png" alt="rooster pagina" width="150" />
  <br>
  <strong>xrooster</strong>
  <br><br>
  Een open-source mobiele app om je <a href="https://myx.nl">myx rooster</a> te bekijken.
  <br>
  Gemaakt voor studenten van scholen die myx gebruiken hun rooster.
  <br><br>
  Alle ondersteunde scholen zijn te vinden in
  <code>assets/schools.json</code>.
  <br>
  Staat jouw school er niet tussen? Maak dan een
  <a href="https://github.com/PhoebeSoftware/xrooster/issues">issue</a>
  aan.
</p>




## Installatie

### Optie 1: Download de laatste release
Download de nieuwste versie van de app via de [releases pagina](https://github.com/PhoebeSoftware/xrooster/releases/latest).

### Optie 2: Zelf bouwen

```bash
git clone https://github.com/PhoebeSoftware/xrooster.git
cd xrooster
flutter pub get
flutter build apk --release
```

De APK bevindt zich dan in `./build/app/outputs/flutter-apk/app-release.apk`

### Optie 3: Debug mode

```bash
git clone https://github.com/PhoebeSoftware/xrooster.git
cd xrooster
flutter pub get
flutter run
```

# Screenshots
## Rooster

<p float="Schedule">
    <img src="./fastlane/metadata/android/en-US/images/phoneScreenshots/1.png" alt="rooster pagina" width="200" />
    <img src="./fastlane/metadata/android/en-US/images/phoneScreenshots/2.png" alt="extra info tab" width="200" />
</p>

## Zoeken

<p float="Schedule">
    <img src="./fastlane/metadata/android/en-US/images/phoneScreenshots/3.png" alt="zoeken" width="200" />
</p>

## Instellingen

<p float="Instellingen">
    <img src="./fastlane/metadata/android/en-US/images/phoneScreenshots/4.png" alt="instellingen" width="200" />
</p>
