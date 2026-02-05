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
<a href="#ondersteunde-scholen">Ondersteunde scholen</a>
  <br><br>

  <a href="https://apt.izzysoft.de/packages/com.phoebesoftware.xrooster">
    <img
      src="https://gitlab.com/IzzyOnDroid/repo/-/raw/master/assets/IzzyOnDroidButtonGreyBorder_nofont.png"
      height="60"
      alt="Get it at IzzyOnDroid"
    />
  </a>
  <br>
  <a href="https://apps.obtainium.imranr.dev/redirect.html?r=obtainium://app/%7B%22id%22%3A%22com.phoebesoftware.xrooster%22%2C%22url%22%3A%22https%3A%2F%2Fgithub.com%2FPhoebeSoftware%2Fxrooster%22%2C%22author%22%3A%22Phoebe%20Software%22%2C%22name%22%3A%22xrooster%22%2C%22additionalSettings%22%3A%22%7B%5C%22includePrereleases%5C%22%3Afalse%7D%22%7D">
    <img
    src="https://github.com/ImranR98/Obtainium/blob/main/assets/graphics/badge_obtainium.png?raw=true"
    height="60">
  </a>
</p>


[![GitHub Release](https://img.shields.io/github/v/release/phoebesoftware/xrooster?label=GitHub&style=for-the-badge)](https://github.com/phoebesoftware/xrooster/releases/latest)

[![IzzyOnDroid](https://img.shields.io/endpoint?url=https://apt.izzysoft.de/fdroid/api/v1/shield/com.phoebesoftware.xrooster&label=IzzyOnDroid&style=for-the-badge)](https://apt.izzysoft.de/packages/com.phoebesoftware.xrooster)

[![RB Status](https://shields.rbtlog.dev/simple/com.phoebesoftware.xrooster?label=RB%20Status&style=for-the-badge)](https://apt.izzysoft.de/packages/com.phoebesoftware.xrooster)

## Ondersteunde scholen

De lijst hieronder wordt automatisch gegenereerd vanuit
<a href="./assets/schools.json"><code>assets/schools.json</code></a>.

<!-- schools_start -->
| School | URL |
| --- | --- |
| Talland College | [talland.myx.nl](https://talland.myx.nl) |
| Konign Willem 1 College | [kw1college.myx.nl](https://kw1college.myx.nl) |
| NHL Stenden | [nhlstenden.myx.nl](https://nhlstenden.myx.nl) |
<!-- schools_end -->

Staat jouw school er niet tussen? Maak dan een <a href="https://github.com/PhoebeSoftware/xrooster/issues">issue</a> of een <a href="https://github.com/PhoebeSoftware/xrooster/pulls">pull request</a> aan.

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
