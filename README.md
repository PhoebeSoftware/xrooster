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
  <a href="./assets/schools.json"><code>assets/schools.json</code></a>.
  <br>
  Staat jouw school er niet tussen? Maak dan een
  <a href="https://github.com/PhoebeSoftware/xrooster/issues">issue</a> of een <a href="https://github.com/PhoebeSoftware/xrooster/pulls">pull request</a>
  aan.
  <br><br>

  <a href="https://apt.izzysoft.de/packages/com.phoebesoftware.xrooster">
    <img
      src="https://gitlab.com/IzzyOnDroid/repo/-/raw/master/assets/IzzyOnDroidButtonGreyBorder_nofont.png"
      height="60"
      alt="Get it at IzzyOnDroid"
    />
  </a>
</p>


[![GitHub Release](https://img.shields.io/github/v/release/phoebesoftware/xrooster?label=GitHub&style=for-the-badge)](https://github.com/phoebesoftware/xrooster/releases/latest)

[![IzzyOnDroid](https://img.shields.io/endpoint?url=https://apt.izzysoft.de/fdroid/api/v1/shield/com.phoebesoftware.xrooster&label=IzzyOnDroid&style=for-the-badge)](https://apt.izzysoft.de/packages/com.phoebesoftware.xrooster)

[![RB Status](https://shields.rbtlog.dev/simple/com.phoebesoftware.xrooster?label=RB%20Status&style=for-the-badge)](https://apt.izzysoft.de/packages/com.phoebesoftware.xrooster)

## Installatie

### Optie 1: Download van IzzyOnDroid (aanbevolen)
Voeg de [IzzyOnDroid](https://apt.izzysoft.de/fdroid/) repo toe aan je f-droid app en installeer [xrooster](https://apt.izzysoft.de/packages/com.phoebesoftware.xrooster)

### Optie 2: Download de laatste release
Download de nieuwste versie van de app via de [releases pagina](https://github.com/PhoebeSoftware/xrooster/releases/latest).

### Optie 3: Zelf bouwen

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
