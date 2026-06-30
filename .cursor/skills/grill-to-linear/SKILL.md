---
name: grill-to-linear
description: >-
  Erstellt aus einer abgeschlossenen Grill-Session (grill-me) ein Linear-Projekt
  mit ausführlichen Issues auf Deutsch inkl. Labels. Sucht bestehende Issue- und
  Projekt-Labels im Linear-Workspace und Team, ordnet sie pro Issue zu. Nutzen
  nach Planungs-/Architektur-Diskussionen. Trigger: grill-to-linear, Linear-Projekt
  aus Grill-Session, Issues aus Planung erstellen, Plan in Linear überführen.
---

# Grill to Linear

Erweiterung zu **grill-me**: Nach der Planungsdiskussion die Erkenntnisse in ein
strukturiertes Linear-Projekt mit detaillierten Issues überführen.

**Sprache:** Alle Projekttexte, Issue-Titel und Issue-Beschreibungen **immer auf Deutsch**.
Technische Begriffe (CLI-Befehle, Dateipfade, AWS-Service-Namen, Code) dürfen Englisch bleiben.

## Wann anwenden

- Direkt nach einer **grill-me**-Session oder einer vergleichbaren Planungsdiskussion
- User bittet um Linear-Projekt/Issues aus dem Chat-Kontext
- Architektur-, Migrations- oder Feature-Plan soll in umsetzbare Tickets zerlegt werden

## Voraussetzungen

- **Linear MCP** muss verfügbar sein (`plugin-linear-linear`)
- Vor jedem MCP-Aufruf: Tool-Schema in `mcps/plugin-linear-linear/tools/` lesen
- Team standardmäßig: **Engineering** (via `list_teams` verifizieren, falls unklar)

## Workflow

```
Fortschritt:
- [ ] 1. Kontext aus Grill-Session extrahieren
- [ ] 2. Bestehende Linear-Labels ermitteln
- [ ] 3. Projektstruktur entwerfen (inkl. Label-Zuordnung)
- [ ] 4. Linear-Projekt anlegen (mit Projekt-Labels)
- [ ] 5. Issues anlegen (mit Abhängigkeiten und Labels)
- [ ] 6. Ergebnis zusammenfassen
```

### Schritt 1 — Kontext extrahieren

Aus dem Chat (Frage-Antwort-Paare, Entscheidungen, offene Punkte) destillieren:

| Element | Quelle |
|---------|--------|
| **Ziel & Motivation** | Warum machen wir das? |
| **Scope** | Was ist drin / explizit draußen? |
| **Architektur** | Services, Komponenten, Datenfluss |
| **Phasen** | Logische Implementierungsreihenfolge |
| **Erfolgskriterien** | Wann ist das Projekt fertig? |
| **Repo-Bezug** | Relevante Dateien, Docs, bestehende Patterns |
| **Risiken/Constraints** | Kosten, YAGNI, Abwärtskompatibilität |

Fehlende Infos **nicht raten** — kurz nachfragen.

Optional: Codebase kurz scannen, wenn Issues konkrete Pfade/Module referenzieren sollen.

### Schritt 2 — Bestehende Linear-Labels ermitteln

**Vor** dem Anlegen von Projekt und Issues alle verfügbaren Labels abfragen und
eine Zuordnungstabelle vorbereiten. Keine neuen Labels erfinden.

#### Label-Quellen abfragen (alle drei, paginieren falls `hasNextPage`)

| Quelle | MCP-Tool | Parameter |
|--------|----------|-----------|
| Workspace / Organisation | `list_issue_labels` | ohne `team` |
| Team (z. B. Engineering) | `list_issue_labels` | `team: "Engineering"` |
| Projekt-Labels | `list_project_labels` | — |

Ergebnisse zusammenführen und deduplizieren (nach `name`). Pro Label notieren:
Name, ID, Scope (Workspace / Team / Projekt), Beschreibung.

#### Label-Kategorien erkennen

Typische Label-Gruppen in Linear-Workspaces (Namen variieren — immer aus API lesen):

| Kategorie | Beispiele | Wofür |
|-----------|-----------|-------|
| **Typ** | `Feature`, `Bug`, `Refactoring` | Art der Arbeit |
| **Repository** | `chroodhq/hueter-intelligence` | Betroffenes Repo |
| **Produkt/Hardware** | `hüter-mk1`, `logic-board` | Produktbezug |
| **Meta** | `long-running` | Besondere Planung |

Details und Zuordnungsregeln: [templates.md](templates.md#label-zuordnung)

#### Label-Zuordnung pro Issue planen

Beim Entwurf in Schritt 3 jedem Issue **1–3 Labels** zuweisen:

1. **Typ-Label** (Pflicht) — z. B. `Feature` für neues, `Refactoring` für Umbau
2. **Repo-Label** (Pflicht, wenn vorhanden) — passend zum bearbeiteten Repository
3. **Optional** — Produkt-, Meta- oder Projekt-Label bei klarem Bezug

Kein Issue ohne mindestens Typ-Label. Labels nur per exaktem Namen aus der
Abfrage verwenden (`labels: ["Feature", "chroodhq/hueter-intelligence"]`).

Neues Label **nur** anlegen (`create_issue_label`), wenn kein bestehendes passt
und der User explizit wünscht oder der Skill es als Lücke dokumentiert.

### Schritt 3 — Projektstruktur entwerfen

Issues so schneiden, dass jedes Ticket:

- **eine klar abgrenzbare Verantwortung** hat (SRP)
- **in 1–3 Tagen** umsetzbar ist (Richtwert)
- **testbare Akzeptanzkriterien** hat
- **Abhängigkeiten** zu anderen Issues explizit macht

Typische Issue-Kategorien (nur wenn passend):

1. Design/Spec (Layout, Konventionen, ADR)
2. Code-Grundlagen (Config, Abstraktionen)
3. Infrastruktur (Cloud-Ressourcen, IAM, CI)
4. Integrations-Schritte (Jobs, Workflows, APIs)
5. Orchestrierung (GHA, Step Functions)
6. Validierung & Runbook

Reihenfolge festlegen, `blockedBy`-Kette und **Label-Zuordnung** planen.

### Schritt 4 — Linear-Projekt anlegen

`save_project` mit:

| Feld | Inhalt |
|------|--------|
| `name` | Prägnanter deutscher Name |
| `summary` | Max. 255 Zeichen, Deutsch |
| `description` | Ausführlich — siehe [templates.md](templates.md#projektbeschreibung) |
| `addTeams` | `["Engineering"]` |
| `state` | `planned` |
| `icon` | Passend zum Thema (z. B. `Cloud`, `Rocket`, `Chip`) |
| `labels` | Passende **Projekt-Labels** aus `list_project_labels` (z. B. `hüter-mk1`) |

Projekt-Labels nur aus `list_project_labels` — Issue-Labels funktionieren hier nicht.

### Schritt 5 — Issues anlegen

Pro Issue `save_issue` mit:

| Feld | Inhalt |
|------|--------|
| `title` | Deutsch, imperativ, konkret |
| `description` | Ausführlich — siehe [templates.md](templates.md#issue-beschreibung) |
| `team` | `Engineering` |
| `project` | Projektname aus Schritt 4 |
| `priority` | `2` (High) für kritischen Pfad, `3` (Medium) für Abschluss/Docs |
| `labels` | 1–3 Labels aus Schritt 2 (exakte Namen) |
| `blockedBy` | Abhängige Issue-IDs (z. B. `["ENG-667"]`) |

**Reihenfolge:** Zuerst Issues ohne Blocker anlegen, dann abhängige — IDs für
`blockedBy` aus den Antworten übernehmen.

**Linear MCP Hinweise:**

- Markdown-Beschreibungen mit echten Zeilenumbrüchen senden, keine `\n`-Escapes
- Issue-Referenzen im Text als `ENG-XXX` — Linear verlinkt automatisch
- Links zu Repo-Dateien via `links: [{url, title}]` anhängen, wo sinnvoll

### Schritt 6 — Zusammenfassung

Dem User auf Deutsch mitgeben:

- Link zum Linear-Projekt (inkl. gesetzter Projekt-Labels)
- Tabelle aller Issues (ID, Titel, Labels, Abhängigkeiten)
- Empfohlene Start-Reihenfolge
- Offene Entscheidungen, die im Grill offen blieben
- Fehlende Labels, für die kein passendes bestehendes Label gefunden wurde

## Qualitätskriterien

Jedes Issue muss enthalten:

- **Ziel** — Was soll am Ende existieren?
- **Kontext** — Warum, Bezug zu Architektur/Repo
- **Aufgaben** — Konkrete Schritte, ggf. Code-Snippets
- **Akzeptanzkriterien** — Checkbox-Liste
- **Nicht im Scope** — Klare Abgrenzung
- **Labels** — Mindestens Typ + Repo (via `save_issue`, nicht in der Beschreibung)

Projektbeschreibung muss enthalten:

- Hintergrund, Ziel, Zielarchitektur (Diagramm wenn hilfreich)
- Phasen, Erfolgskriterien, projektweites Out-of-Scope
- Repo-Referenzen

## Anti-Patterns

- Keine vagen Issues wie „AWS einrichten" — konkretisieren
- Kein Mega-Issue, das Design + Code + Infra + CI vermischt
- Keine englischen Titel/Beschreibungen (User-Vorgabe)
- Keine Issues ohne Out-of-Scope — verhindert Scope Creep
- Keine Issues ohne Labels — mindestens Typ-Label setzen
- Keine erfundenen Label-Namen — immer aus `list_issue_labels` / `list_project_labels`
- Nicht committen/pushen — nur Linear anlegen

## Referenz

- Issue- und Projekt-Templates: [templates.md](templates.md)
- Paar-Skill für Planung: [grill-me](../grill-me/SKILL.md)
