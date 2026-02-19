# Schach Simple – GitHub Setup (DE)

Dieses ZIP enthält **nur den App‑Code + Assets** (UIKit, iOS 12+) – damit du ihn in ein **eigenes Xcode‑Projekt** einfügst und dann auf GitHub pushst.
Der Schach‑Regelteil/AI kommt über **SwiftChess** als Dependency (Swift Package Manager).

## 1) Xcode Projekt erstellen
1. Xcode → **File → New → Project…**
2. iOS → **App**
3. Interface: **Storyboard** (oder SwiftUI aus – wir nutzen UIKit)
4. Language: **Swift**
5. Deployment Target später auf **iOS 12.0** stellen

## 2) Bundle Identifier (das musst du eingeben)
Xcode → Project (blaues Icon) → **TARGETS** → dein Target → **Signing & Capabilities**
- **Automatically manage signing** ✅
- **Team**: deinen Apple Account wählen
- **Bundle Identifier**:
  - `com.zaxooo.schach.simple`
  - falls schon vergeben: `com.zaxooo.schach.simple2026`

## 3) SwiftChess als Package hinzufügen (für offizielle Zugregeln + AI)
Xcode → **File → Add Package Dependencies…**
- URL: `https://github.com/SteveBarnegren/SwiftChess`
- Add to Target: dein App‑Target

## 4) Code aus diesem ZIP ins Projekt kopieren
Ziehe die Ordner in Xcode (Project Navigator):
- `App/`
- `Bootstrap/`
- `Assets/`

**Wichtig beim Reinziehen:** Haken bei deinem Target setzen.

Dann:
- In deinem Target unter **General → App Icons and Launch Images**
  - App Icon Source: `AppIcon`
- `Assets.xcassets` öffnen → `AppIcon` → das 1024×1024 Icon aus `Assets/AppIcon-1024.png` ins 1024‑Feld ziehen.

## 5) Storyboard deaktivieren (UIKit ohne Storyboard)
1. Entferne in **Info.plist** den Eintrag `UIApplicationSceneManifest` nicht, aber:
2. In **TARGETS → General**
   - **Main Interface** leeren (falls vorhanden)
3. In `SceneDelegate.swift` (liegt in `Bootstrap/`) ist bereits der Start über `UINavigationController(root: MenuViewController())` vorbereitet.

## 6) Fix für Xcode-Fehler „Resources could not be opened“
Wenn links ein roter Eintrag **Resources** auftaucht:
- Rechtsklick → **Delete** → **Remove Reference** (nicht „Move to Trash“)

## 7) GitHub Repo anlegen & pushen
### A) Repo auf GitHub erstellen
GitHub → **New repository** → z.B. `SchachSimple`

### B) Lokal initialisieren und pushen
Im Projektordner (Terminal):
```bash
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/DEINNAME/SchachSimple.git
git push -u origin main
```

## 8) Was auf GitHub NICHT rein soll
- `DerivedData/`
- Zertifikate/Keys
- Tokens/Passwörter

Dafür ist die `.gitignore` im ZIP schon dabei.
