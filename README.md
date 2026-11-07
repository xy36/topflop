# TopFlop

Persönliche Produktbewertungen für den Einkauf. Du scannst den Barcode, bewertest das Produkt mit 1–10 (Emoji-Skala) und hältst fest, ob du es wieder kaufen würdest und in welchem Laden es das gab. Vor dem Regal findest du so sofort wieder, was dir geschmeckt hat.

## Funktionen

- **Scanner:** Barcode scannen (EAN/UPC). Die Produktdaten und Bilder kommen von [Open Food Facts](https://world.openfoodfacts.org); für andere Produkte wird zusätzlich bei Open Beauty Facts und Open Products Facts gesucht. Bereits bewertete Produkte zeigen direkt dein Urteil.
- **Bewertung:** einrastender Slider 1–10 mit Emoji, „Würde ich wieder kaufen“, Läden, Preis und Notiz. Pro Produkt gibt es genau eine Bewertung, die sich ändern lässt.
- **Übersicht:** Suche, Laden-Schnellfilter, Filter (Bewertung, Kategorie, Favoriten, Wieder kaufen), Favoriten-Herz.
- **Läden:** Ketten wie „Lidl“, ganz ohne Standort. Beim Bewerten sind die Läden der letzten Bewertung vorausgewählt.
- **Produkte ohne Barcode** (Frischetheke, Wochenmarkt) lassen sich selbst anlegen.
- **Sprachen:** Deutsch, Englisch, Französisch, Spanisch, Italienisch und Niederländisch.
- **Backup:** automatisch über Android Auto Backup bzw. iCloud, zusätzlich manueller Export und Import als JSON (Einstellungen).

## Technik

| Bereich | Lösung |
| --- | --- |
| State | `flutter_riverpod` |
| Navigation | `go_router` |
| Datenbank | `drift` (SQLite, lokal) |
| Scanner | `mobile_scanner` |
| Lokalisierung | `gen-l10n`, ARB-Dateien in `lib/l10n/` |

Es gibt kein eigenes Backend: Alle Daten liegen lokal auf dem Gerät. Die Repositories in `lib/data/repositories/` kapseln den Datenzugriff, damit später ein Sync nachgerüstet werden kann.

```
lib/
  app/        App, Router, Navigationsgerüst
  core/       Theme, Domain (Kategorien, Skala), gemeinsame Widgets
  data/       Datenbank, Open Food Facts, Backup, Provider
  features/   home, scanner, product, rating, stores, settings
  l10n/       Übersetzungen (app_de.arb ist die Vorlage)
```

## Entwicklung

```bash
flutter pub get
dart run build_runner build   # nach Änderungen an lib/data/db/database.dart
flutter test
flutter run
```

Die Lokalisierungen werden bei `flutter run` bzw. `flutter gen-l10n` automatisch erzeugt.

### Neue Sprache hinzufügen

1. `lib/l10n/app_de.arb` nach `lib/l10n/app_<code>.arb` kopieren und übersetzen.
2. Bei iOS den Sprachcode zusätzlich in `ios/Runner/Info.plist` unter `CFBundleLocalizations` eintragen.
3. Bei Android den Sprachcode in `android/app/src/main/res/xml/locales_config.xml` eintragen (App-Sprache in den Systemeinstellungen ab Android 13).
4. Den Sprachcode in den Test „Alle Übersetzungen haben dieselben Schlüssel …“ in `test/app_test.dart` aufnehmen.

### iOS

Bauen und Testen auf einem Mac mit Xcode:

```bash
flutter build ios
```

Falls `mobile_scanner` beim ersten Build eine höhere Mindestversion verlangt, setzt du das Deployment Target in Xcode (Runner → General → Minimum Deployments) entsprechend hoch.

## Releases

Releases laufen über [release-please](https://github.com/googleapis/release-please)
(`.github/workflows/release-please.yml`). Dafür brauchen Commit-Nachrichten auf
`main` das Format [Conventional Commits](https://www.conventionalcommits.org/de/):

| Präfix | Wirkung |
| --- | --- |
| `feat: …` | neue Funktion, erhöht die Minor-Version (0.6.0 → 0.7.0) |
| `fix: …` | Fehlerbehebung, erhöht die Patch-Version (0.6.0 → 0.6.1) |
| `feat!: …` oder `BREAKING CHANGE:` im Text | vor 1.0 nur die Minor-Version, danach die Major-Version |
| `docs:`, `refactor:`, `test:`, `build:`, `ci:`, `chore:` | kein neues Release, nicht im Changelog |

release-please hält danach einen Release-PR offen, der `CHANGELOG.md` und die
Version in `pubspec.yaml` fortschreibt. Die Build-Nummer hinter dem `+` zählt dabei
automatisch hoch, wie es der Play Store verlangt. Wird der PR gemergt, entstehen
Tag und GitHub-Release.

Während der Testphase bleibt die Version unter 1.0. Für das erste stabile Release
einen Commit mit der Zeile `Release-As: 1.0.0` im Text pushen.

## Datenquellen

- Produktdaten und Bilder: Open Food Facts, lizenziert unter der Open Database License (ODbL).
