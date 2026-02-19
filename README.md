# Schach iPhone App (UIKit, iOS 12+)

Dieses ZIP enthält **fertige Swift-Dateien** für eine schlichte Schach-App:
- **Computergegner** (leicht/mittel/schwer)
- **Farbwahl**: Weiß oder Schwarz
- **Punkte pro Sieg** (10/20/30)
- **FIDE-Regeln inkl. Remis-Regeln** (Patt, Dead Position, 3x/5x Wiederholung, 50-/75-Züge)

## Wichtig: Schachregeln „offiziell“
Die **FIDE Laws of Chess (01/01/2023)** enthalten **Unentschieden** als offizielle Ergebnisse (z. B. Patt, Dead Position, Wiederholung, 50‑Züge‑Regel). 
Diese App implementiert diese Remis-Regeln entsprechend (Claimable vs. Automatic), siehe FIDE Artikel 5.2 und 9.2/9.3/9.6.

## Installation (Xcode)
1. **Neues Projekt**: iOS → App → **UIKit** → Sprache **Swift**.
2. Deployment Target: **iOS 12.0**.
3. **SwiftChess als Dependency hinzufügen** (empfohlen):
   - Xcode: *File → Add Package Dependencies…*
   - URL: `https://github.com/SteveBarnegren/SwiftChess`
   - Dann im Target bei *Frameworks, Libraries, and Embedded Content* prüfen, dass SwiftChess hinzugefügt ist.

4. **Diese Dateien hinzufügen**:
   - Ziehe den Ordner `App/` und `Bootstrap/` in dein Xcode-Projekt ("Copy items if needed" + Target aktivieren).

5. **Storyboard deaktivieren (programmatischer Start)**:
   - Entferne in `Info.plist` den Key **Main storyboard file base name** (`UIMainStoryboardFile`).
   - Falls vorhanden, entferne auch **Storyboard Name** in den Scene-Settings.

6. Starten.

## Was ist bereits drin?
- Unicode-Figuren (♟︎ etc.), kein Asset-Setup nötig.
- KI zieht asynchron.
- Remis:
  - **Patt** automatisch.
  - **Dead Position** (klassische sichere Muster) automatisch.
  - **3x Wiederholung / 50‑Züge**: der Spieler **kann** reklamieren.
  - **5x Wiederholung / 75‑Züge**: automatisch.

## Anpassungen
- Punkte: `App/AppDifficulty.swift` → `winPoints`.
- UI schlicht halten: `ChessViewController` / `MenuViewController`.



## GitHub
Siehe `README_GITHUB_DE.md` für Setup + .gitignore.
