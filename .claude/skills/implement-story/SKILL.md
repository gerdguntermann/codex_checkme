---
name: implement-story
description: >
  Implementiert eine GitHub Issue (User Story) vollständig nach Clean Architecture.
  Nutze diesen Skill immer wenn der Nutzer eine Issue-Nummer nennt und diese umsetzen
  möchte, z.B. "implementiere Issue #17", "setz Story #5 um", "arbeite an Ticket #12",
  oder "starte Feature #8". Auch bei Formulierungen wie "nächste Story", "aktuelle Story"
  oder "arbeite am Backlog" diesen Skill verwenden. Der Skill liest die Issue aus GitHub,
  legt einen Feature-Branch an, implementiert nach CLAUDE.md-Regeln und erstellt einen PR.
---

# Skill: implement-story

Setzt eine GitHub Issue (User Story) vollständig um – von Branch-Erstellung bis Pull Request.

---

## Voraussetzungen

- `gh` CLI installiert und authentifiziert (`gh auth status`)
- `git` verfügbar
- `CLAUDE.md` im Projekt-Root vorhanden
- GitHub Repository verbunden (`git remote -v`)

---

## Workflow

### Schritt 1 – Issue lesen

```bash
gh issue view {ISSUE_NUMMER} --json number,title,body,labels,milestone
```

Extrahiere aus der Issue:
- **Titel** → für Branch-Name und PR-Titel
- **Body** → User Story + Akzeptanzkriterien
- **Labels** → Feature-Bereich (z.B. `check-in`, `config`, `contacts`)
- **Milestone** → Epic-Zugehörigkeit

Wenn die Issue nicht existiert oder keine Akzeptanzkriterien enthält: Nutzer fragen bevor fortgefahren wird.

---

### Schritt 2 – Branch anlegen

Branch-Name Schema: `feature/{nummer}-{slug}`

Slug-Regeln:
- Titel in Kleinbuchstaben
- Leerzeichen → Bindestriche
- Sonderzeichen entfernen
- Maximal 40 Zeichen

```bash
git checkout main
git pull origin main
git checkout -b feature/{nummer}-{slug}
```

Beispiel: Issue #17 „Push Notifications für Überfälligkeit" → `feature/17-push-notifications-ueberfaelligkeit`

---

### Schritt 3 – CLAUDE.md lesen

Lies `CLAUDE.md` vollständig. Beachte insbesondere:
- Architektur-Regeln (Clean Architecture Schichten)
- Coding-Regeln (was erlaubt/verboten ist)
- Den 9-Schritte Feature-Workflow
- Tech-Stack (Riverpod, GoRouter, GetIt, dartz)

---

### Schritt 4 – Implementierung

Folge dem **9-Schritte Clean Architecture Workflow** aus `CLAUDE.md`:

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

### Schritt 5 – Commit

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

### Schritt 6 – Pull Request erstellen

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

---

## Ausgabe am Ende

Zeige dem Nutzer:
1. PR-URL
2. `git diff main...HEAD --stat` (Übersicht der Änderungen)
3. Offene Punkte / bekannte Einschränkungen (falls vorhanden)

**Kein vollständiges File-Listing ausgeben** – nur diff und PR-Link.

---

## Fehlerbehandlung

| Problem | Lösung |
|---|---|
| `gh` nicht authentifiziert | `gh auth login` ausführen und Nutzer anleiten |
| Issue hat keine Akzeptanzkriterien | Nutzer fragen: „Was sind die Akzeptanzkriterien für #X?" |
| `flutter analyze` zeigt Fehler | Alle Fehler beheben, kein PR mit Analysefehlern |
| Branch existiert bereits | Nutzer fragen ob fortgesetzt oder neu begonnen werden soll |
| Merge-Konflikt | Nutzer informieren, gemeinsam lösen |
