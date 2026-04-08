---
name: new-story
description: >
  Erstellt eine neue GitHub Issue als strukturierte User Story mit Akzeptanzkriterien,
  Labels und Milestone-Zuweisung. Nutze diesen Skill immer wenn der Nutzer eine neue
  Anforderung, ein neues Feature oder eine neue Funktion beschreiben möchte, z.B.
  "neue Story", "neue Anforderung", "ich brauche ein Feature für X", "füge ins Backlog
  hinzu", "erstelle ein Ticket für", "neue User Story". Auch bei vagen Formulierungen
  wie "ich möchte dass die App X kann" oder "wir brauchen noch Y" diesen Skill verwenden.
  Der Skill führt den Nutzer durch die Story-Erstellung und legt das Issue direkt in
  GitHub an.
---

# Skill: new-story

Nimmt eine neue Anforderung auf, strukturiert sie als User Story und legt sie als GitHub Issue an.

---

## Voraussetzungen

- `gh` CLI installiert und authentifiziert (`gh auth status`)
- GitHub Repository verbunden
- GitHub Project (Kanban Board) angelegt (optional)

---

## Workflow

### Schritt 1 – Anforderung verstehen

Frage den Nutzer nach folgenden Informationen. Stelle **nicht alle Fragen auf einmal** – beginne mit dem Was, leite dann zu Details über:

**Pflichtfelder:**
- Was soll die App können? (freie Beschreibung)
- Aus wessen Perspektive? (Nutzer / Administrator / System)
- Warum ist das wichtig? (Nutzen / Ziel)

**Optional (kannst du aus der Beschreibung ableiten):**
- Welchem Epic/Milestone gehört das an?
- Gibt es bekannte Einschränkungen oder Abhängigkeiten?

---

### Schritt 2 – Story formulieren

Forme die Antworten in das Standard-Format:

```
Als {Rolle}
möchte ich {Funktion}
damit {Nutzen/Ziel}
```

Leite daraus **3–5 Akzeptanzkriterien** ab. Format:

```
- [ ] {Konkretes, testbares Kriterium}
```

Zeige dem Nutzer die fertige Story zur Bestätigung bevor das Issue angelegt wird.

---

### Schritt 3 – Labels bestimmen

Weise passende Labels zu. Prüfe zuerst welche Labels im Repo existieren:

```bash
gh label list
```

Empfohlene Labels für CheckMe:

| Label | Bedeutung |
|---|---|
| `story` | User Story (Standard für neue Features) |
| `bug` | Fehlerbehebung |
| `tech-debt` | Technische Verbesserung ohne User-Sichtbarkeit |
| `check-in` | Feature-Bereich: Check-in Logik |
| `config` | Feature-Bereich: Konfiguration |
| `contacts` | Feature-Bereich: Notfallkontakte |
| `notifications` | Feature-Bereich: Benachrichtigungen |
| `background` | Feature-Bereich: Hintergrund-Service |

Fehlende Labels anlegen:
```bash
gh label create "story" --color "#0075ca" --description "User Story"
gh label create "notifications" --color "#e4e669" --description "Benachrichtigungen"
```

---

### Schritt 4 – Milestone zuweisen

```bash
gh milestone list
```

Zeige dem Nutzer die offenen Milestones (= Epics). Frage welchem Epic die Story zugehört.

Wenn kein passender Milestone existiert, fragen ob ein neuer angelegt werden soll:
```bash
gh milestone create \
  --title "{Epic-Name}" \
  --description "{Kurzbeschreibung des Epics}"
```

---

### Schritt 5 – Issue anlegen

```bash
gh issue create \
  --title "Als {Rolle} möchte ich {kurzform}" \
  --body "## User Story

Als {Rolle}
möchte ich {Funktion}
damit {Nutzen/Ziel}

## Akzeptanzkriterien

- [ ] {Kriterium 1}
- [ ] {Kriterium 2}
- [ ] {Kriterium 3}

## Notizen

{Technische Hinweise oder bekannte Einschränkungen, falls vorhanden}" \
  --label "{label1},{label2}" \
  --milestone "{milestone-name}"
```

---

### Schritt 6 – Issue ins Kanban Board aufnehmen

Prüfe ob GitHub Project-Daten in `AGENTS.md` hinterlegt sind (Abschnitt „GitHub Project").

**Falls Project-Nr bekannt:**
```bash
# Issue zum Board hinzufügen (landet automatisch in der ersten Spalte)
gh project item-add {PROJECT_NR} \
  --owner {github-username} \
  --url {ISSUE_URL}
```

Das Issue landet damit automatisch im **Backlog** des Kanban Boards.

**Falls Project-Nr unbekannt:**
```bash
gh project list --owner {github-username}
```
Project-Nr anzeigen, Nutzer fragen ob sie in `AGENTS.md` gespeichert werden soll.

---

## Ausgabe am Ende

Zeige dem Nutzer:
1. Issue-URL und Nummer (z.B. `#18`)
2. Kanban-Status: „Issue liegt im Backlog" (oder Hinweis falls Board nicht konfiguriert)
3. Den fertigen Story-Text zur Referenz
4. Hinweis: `Zum Implementieren: /implement-story #{nummer}`

---

## Kanban Board – Gesamtübersicht der Statusübergänge

```
Backlog     → [new-story legt hier ab]           ← dieser Skill
Ready       → [manuell: Story ist bereit]
In Progress → [implement-story: Branch erstellt]
In Review   → [implement-story: PR erstellt]
Done        → [automatisch: PR gemergt]
```

---

## Tipps für gute Akzeptanzkriterien

- **Testbar**: Kann ein Mensch oder automatischer Test prüfen ob es erfüllt ist
- **Konkret**: Keine vagen Formulierungen wie „funktioniert gut"
- **Aus Nutzersicht**: Was sieht/erlebt der Nutzer, nicht wie es technisch umgesetzt wird

**Beispiel (schlecht):** „Benachrichtigung funktioniert"
**Beispiel (gut):** „Wird kein Check-in innerhalb der Karenzzeit durchgeführt, erhalten alle aktiven Kontakte eine E-Mail innerhalb von 2 Minuten"

---

## Fehlerbehandlung

| Problem | Lösung |
|---|---|
| `gh` nicht authentifiziert | `gh auth login` ausführen |
| Milestone nicht gefunden | Neuen Milestone anlegen oder ohne zuweisen |
| Label existiert nicht | Label anlegen (Schritt 3) |
| Nutzer-Beschreibung zu vage | Nachfragen: „Was genau soll der Nutzer tun können?" |
| Project-Nr unbekannt | `gh project list` ausführen, Nutzer fragen ob in AGENTS.md speichern |
| `item-add` schlägt fehl | Issue-URL prüfen, Project-Nr verifizieren |
