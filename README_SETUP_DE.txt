# SchachApp Starter – Setup (iOS 12+ / UIKit)

## 1) Bundle Identifier setzen
Xcode → Project (blaues Icon) → TARGETS → dein Target → Signing & Capabilities → Bundle Identifier.

Vorschlag:
- com.zaxooo.schach.simple

Wichtig: Der Bundle Identifier muss in deinem Apple Developer Account eindeutig sein.
Wenn Xcode meckert, ändere z. B.:
- com.zaxooo.schach.simple2026

## 2) App Icon hinzufügen
Im Ordner `Assets/` liegt `AppIcon-1024.png`.

Xcode:
1. Assets.xcassets öffnen
2. AppIcon auswählen (oder neu: New App Icon)
3. `AppIcon-1024.png` ins 1024×1024 (App Store) Feld ziehen
   → Xcode erzeugt/verwaltet die übrigen Größen.

## 3) Fehler: "The file \"Resources\" couldn't be opened because there is no such file."
Das ist fast immer nur eine **kaputte Referenz** im Xcode-Projekt.

Fix:
1. Links im Project Navigator den **roten** Eintrag „Resources“ suchen.
2. Rechtsklick → Delete → **Remove Reference** (nicht „Move to Trash“).
3. Product → Clean Build Folder.
