# TopFlop

Persönliche Produktbewertungen für den Einkauf. Du scannst den Barcode, bewertest das Produkt mit 1–10 (Emoji-Skala) und hältst fest, ob du es wieder kaufen würdest und in welchem Laden es das gab. Vor dem Regal findest du so sofort wieder, was dir geschmeckt hat.

## Funktionen

- **Scanner:** Barcode scannen (EAN/UPC). Die Produktdaten und Bilder kommen von [Open Food Facts](https://world.openfoodfacts.org); für andere Produkte wird zusätzlich bei Open Beauty Facts und Open Products Facts gesucht. Bereits bewertete Produkte zeigen direkt dein Urteil.
- **Bewertung:** einrastender Slider 1–10 mit Emoji, „Würde ich wieder kaufen“, Laden, Preis und Notiz. Pro Produkt gibt es einen Verlauf aller Käufe.
- **Übersicht:** Suche, Filter (Favoriten, Wieder kaufen), Favoriten-Herz.
- **Läden:** mit Standort. Der nächste Laden wird beim Bewerten automatisch vorausgewählt. Vorschläge in der Nähe kommen aus OpenStreetMap.
- **Produkte ohne Barcode** (Frischetheke, Wochenmarkt) lassen sich selbst anlegen.
- **Sprachen:** Deutsch und Englisch.
- **Backup:** automatisch über Android Auto Backup bzw. iCloud, zusätzlich manueller Export und Import als JSON (Einstellungen).

## Technik

| Bereich | Lösung |
| --- | --- |
| State | `flutter_riverpod` |
| Navigation | `go_router` |
| Datenbank | `drift` (SQLite, lokal) |
| Scanner | `mobile_scanner` |
| Standort | `geolocator` |
| Lokalisierung | `gen-l10n`, ARB-Dateien in `lib/l10n/` |

Es gibt kein eigenes Backend: Alle Daten liegen lokal auf dem Gerät. Die Repositories in `lib/data/repositories/` kapseln den Datenzugriff, damit später ein Sync nachgerüstet werden kann.

```
lib/
  app/        App, Router, Navigationsgerüst
  core/       Theme, Domain (Kategorien, Skala), gemeinsame Widgets
  data/       Datenbank, Open Food Facts, OpenStreetMap, Backup, Provider
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

### iOS

Bauen und Testen auf einem Mac mit Xcode:

```bash
flutter build ios
```

Falls `mobile_scanner` beim ersten Build eine höhere Mindestversion verlangt, setzt du das Deployment Target in Xcode (Runner → General → Minimum Deployments) entsprechend hoch.

## Datenquellen

- Produktdaten und Bilder: Open Food Facts, lizenziert unter der Open Database License (ODbL).
- Läden in der Nähe: © OpenStreetMap-Mitwirkende (ODbL).
