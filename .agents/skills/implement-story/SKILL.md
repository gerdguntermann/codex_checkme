---
name: implement-story
description: >
  Implementiert eine GitHub Issue (User Story) vollständig nach Clean Architecture.
  Nutze diesen Skill immer wenn der Nutzer eine Issue-Nummer nennt und diese umsetzen
  möchte, z.B. "implementiere Issue #17", "setz Story #5 um", "arbeite an Ticket #12",
  oder "starte Feature #8". Auch bei Formulierungen wie "nächste Story", "aktuelle Story"
  oder "arbeite am Backlog" diesen Skill verwenden. Der Skill liest die Issue aus GitHub,
  legt einen Feature-Branch an, implementiert nach AGENTS.md-Regeln und erstellt einen PR.
---

# Skill: implement-story

Setzt eine GitHub Issue (User Story) vollständig um – von Branch-Erstellung bis Pull Request.

---

## Voraussetzungen

- `gh` CLI installiert und authentifiziert (`gh auth status`)
- `git` verfügbar
- `AGENTS.md` im Projekt-Root vorhanden
- GitHub Repository verbunden (`git remote -v`)
- GitHub Project (Kanban Board) angelegt (optional, aber empfohlen)

---

## Kanban-Hilfsfunktionen

### Project-ID ermitteln (einmalig)
```bash
gh project list --owner {github-username}
```
Merke dir die **Project-Nummer** (z.B. `1`) – sie wird in allen Board-Operationen benötigt.

### Item-ID einer Issue ermitteln
```bash
gh project item-list {PROJECT_NR} --owner {github-username} \
  --format json | grep -A5 '"number": {ISSUE_NUMMER}'
```

### Status einer Issue im Board setzen
```bash
# Verfügbare Status-Optionen anzeigen
gh project field-list {PROJECT_NR} --owner {github-username}

# Status setzen (benötigt item-id und field-id aus den obigen Befehlen)
gh project item-edit \
  --project-id {PROJECT_ID} \
  --id {ITEM_ID} \
  --field-id {STATUS_FIELD_ID} \
  --single-select-option-id {OPTION_ID}
```

**Hinweis:** Falls Project-ID oder Field-IDs unbekannt sind, diese einmalig ermitteln und
in `AGENTS.md` unter einem Abschnitt „GitHub Project" dokumentieren, z.B.:
```
## GitHub Project
Project-Nr:      1
Status Field-ID: PVTSSF_xxx
Backlog-ID:      xxx
Ready-ID:        xxx
In Progress-ID:  xxx
In Review-ID:    xxx
Done-ID:         xxx
```

---

## Workflow

### Schritt 1 – Issue lesen & Board aktualisieren

```bash
gh issue view {ISSUE_NUMMER} --json number,title,body,labels,milestone,projectItems
```

Extrahiere aus der Issue:
- **Titel** → für Branch-Name und PR-Titel
- **Body** → User Story + Akzeptanzkriterien
- **Labels** → Feature-Bereich (z.B. `check-in`, `config`, `contacts`)
- **Milestone** → Epic-Zugehörigkeit

Wenn die Issue nicht existiert oder keine Akzeptanzkriterien enthält: Nutzer fragen bevor fortgefahren wird.

**Kanban: Issue → „In Progress" setzen**

Prüfe ob GitHub Project-Daten in `AGENTS.md` hinterlegt sind. Falls ja:
```bash
gh project item-edit \
  --project-id {PROJECT_ID} \
  --id {ITEM_ID} \
  --field-id {STATUS_FIELD_ID} \
  --single-select-option-id {IN_PROGRESS_ID}
```
Falls Project-Daten fehlen: Schritt überspringen und Nutzer am Ende darauf hinweisen.

---

### Schritt 2 – Abhängigkeiten prüfen

Lies den Issue-Body und suche nach Hinweisen auf Abhängigkeiten:
- Schlüsselwörter: „Verwandt mit", „Depends on", „Benötigt", „Blocks", „Blocked by"
- GitHub-Querverweise: `#NNN` im Body

**Für jede gefundene Abhängigkeit:**
```bash
gh issue view {ABHAENGIGE_ISSUE_NR} --json number,title,state,body
```

Entscheide dann:

| Situation | Branch-Basis |
|---|---|
| Keine Abhängigkeit | `main` |
| Abhängige Issue bereits gemergt | `main` |
| Abhängige Issue als offener PR vorhanden | `feature/{andere-nummer}-{slug}` |
| Abhängige Issue noch nicht begonnen | Nutzer fragen: zuerst #X implementieren? |

Informiere den Nutzer kurz über die Entscheidung, bevor der Branch angelegt wird.

---

### Schritt 3 – Branch anlegen

Branch-Name Schema: `feature/{nummer}-{slug}`

Slug-Regeln:
- Titel in Kleinbuchstaben
- Leerzeichen → Bindestriche
- Sonderzeichen entfernen
- Maximal 40 Zeichen

```bash
# Ohne Abhängigkeit:
git checkout main
git pull origin main
git checkout -b feature/{nummer}-{slug}

# Mit Abhängigkeit auf offenen Branch:
git checkout feature/{andere-nummer}-{slug}
git pull origin feature/{andere-nummer}-{slug}
git checkout -b feature/{nummer}-{slug}
```

Beispiel: Issue #17 „Push Notifications für Überfälligkeit" → `feature/17-push-notifications-ueberfaelligkeit`

---

### Schritt 4 – AGENTS.md lesen

Lies `AGENTS.md` vollständig. Beachte insbesondere:
- Architektur-Regeln (Clean Architecture Schichten)
- Coding-Regeln (was erlaubt/verboten ist)
- Den 9-Schritte Feature-Workflow
- Tech-Stack (Riverpod, GoRouter, GetIt, dartz)

---

### Schritt 5 – Implementierung

Folge dem **9-Schritte Clean Architecture Workflow** aus `AGENTS.md`:

1. Entity in `domain/entities/` anlegen oder erweitern
2. Repository-Interface in `domain/repositories/` erweitern
3. UseCase in `domain/usecases/` erstellen
4. Model in `data/models/` anlegen
5. `dart run build_runner build --delete-conflicting-outputs` ausführen
6. DataSource in `data/datasources/` implementieren
7. Repository-Impl in `data/repositories/` implementieren
8. GetIt-Registrierung in `injection_container.dart`
9. Provider + UI in `presentation/` einbauen

**Constraints:**
- Nur Hand-Code ändern, niemals `.g.dart`-Dateien
- `Either<Failure, T>` für alle Repository-Returns
- Keine Flutter/Firebase-Imports im `domain`-Layer
- Maximal 10–15 Dateien pro Schritt

Nach Abschluss der Implementierung:
```bash
flutter analyze
```
Alle Fehler beheben bevor weiter gegangen wird.

---

### Schritt 6 – Commit

```bash
git add .
git diff --staged --stat
```

Zeige den diff dem Nutzer zur Kontrolle, dann:

```bash
git commit -m "feat(#{nummer}): {kurze beschreibung}

{User Story Titel}

Akzeptanzkriterien umgesetzt:
- {kriterium 1}
- {kriterium 2}

Closes #{nummer}"
```

---

### Schritt 7 – Pull Request erstellen & Board aktualisieren

```bash
gh pr create \
  --title "feat(#{nummer}): {titel}" \
  --body "## User Story
Closes #{nummer}

## Änderungen
{Liste der geänderten Bereiche}

## Akzeptanzkriterien
- [ ] {kriterium 1}
- [ ] {kriterium 2}

## Betroffene Schichten
- [ ] domain
- [ ] data
- [ ] presentation
- [ ] background
- [ ] functions (Cloud Functions)" \
  --base main
```

**Kanban: Issue → „In Review" setzen**

```bash
gh project item-edit \
  --project-id {PROJECT_ID} \
  --id {ITEM_ID} \
  --field-id {STATUS_FIELD_ID} \
  --single-select-option-id {IN_REVIEW_ID}
```

---

## Ausgabe am Ende

Zeige dem Nutzer:
1. PR-URL
2. `git diff main...HEAD --stat` (Übersicht der Änderungen)
3. Aktueller Kanban-Status der Issue
4. Offene Punkte / bekannte Einschränkungen (falls vorhanden)

**Kein vollständiges File-Listing ausgeben** – nur diff und PR-Link.

---

## Kanban Board – Gesamtübersicht der Statusübergänge

```
Backlog → [/new-story legt hier ab]
Ready   → [manuell, wenn Story bereit zur Implementierung]
In Progress → [implement-story: Schritt 1, nach Branch-Erstellung]
In Review   → [implement-story: Schritt 6, nach PR-Erstellung]
Done        → [automatisch durch GitHub Workflow wenn PR gemergt]
```

---

## Fehlerbehandlung

| Problem | Lösung |
|---|---|
| `gh` nicht authentifiziert | `gh auth login` ausführen und Nutzer anleiten |
| Issue hat keine Akzeptanzkriterien | Nutzer fragen: „Was sind die Akzeptanzkriterien für #X?" |
| `flutter analyze` zeigt Fehler | Alle Fehler beheben, kein PR mit Analysefehlern |
| Branch existiert bereits | Nutzer fragen ob fortgesetzt oder neu begonnen werden soll |
| Merge-Konflikt | Nutzer informieren, gemeinsam lösen |
| Abhängige Issue noch offen, kein Branch | Nutzer fragen: zuerst #X implementieren? |
| Abhängige Issue im Review (offener PR) | Branch auf `feature/{andere-nr}-{slug}` basieren, PR-Body mit „Depends on #X" kennzeichnen |
| Project-ID fehlt in AGENTS.md | Kanban-Schritte überspringen, Nutzer einmalig anleiten IDs zu ermitteln |
| `item-edit` schlägt fehl | Project-IDs in AGENTS.md prüfen und aktualisieren |
