# Permissions

Ein Redmine-Plugin, das feingranulare Berechtigungen pro Wiki-Seite ermöglicht.  
Mit diesem Plugin kannst du für einzelne Wiki-Seiten Standardzugriffe definieren und individuelle Benutzer-/Mitgliederberechtigungen setzen (z. B. nur lesen, bearbeiten oder Berechtigungen verwalten).

## Features

- Pro Wiki-Seite:
  - Standard-Berechtigungslevel (gilt für Benutzer ohne explizite Regel)
  - Individuelle Berechtigungen pro Mitglied (Member)
- Vier Berechtigungslevel:
  - 0: Zugriff gesperrt
  - 1: Kann einsehen
  - 2: Kann bearbeiten
  - 3: Kann Berechtigungen setzen
- Hook-Integration: Icon in der Wiki-UI, Anpassung von Kontextmenüs und Suchen (versteckte Seiten werden aus Suchergebnissen entfernt)
- Model/Controller-Erweiterungen werden via `prepend` eingebunden

## Kompatibilität

Das Plugin wurde für Redmine (Version >= 6.0.0) entwickelt. Es verwendet Migrationen mit `ActiveRecord::Migration[7.0]`, daher achte auf die Rails-/Redmine-Version deiner Installation.

## Installation

1. In dein Redmine-Verzeichnis wechseln.
2. Das Plugin-Verzeichnis in `plugins/` kopieren und nach Bedarf umbenennen.
3. Migration mit `rake redmine:plugins:migrate RAILS_ENV=production` ausführen.
4. Redmine neu starten.

Hinweis: Falls du ein Versionsverwaltungssystem nutzt, kannst du das Plugin-Repository auch als Unterordner im `plugins/`-Verzeichnis verwalten.

## Nutzung

- Gehe zu einem Projekt-Wiki und öffne eine Wiki-Seite.
- Wenn du die notwendige Berechtigung hast, erscheint in der Seitenleiste / Kontextmenü ein Link „Zugriff“.
- Klick auf „Zugriff“ öffnet die Seite zur Verwaltung der Standard- und individuellen Berechtigungen.
- Standardregel:
  - Wenn keine Standardregel gesetzt ist, verhält sich die Seite wie in Redmine üblich (keine zusätzliche Einschränkung).
  - Die Standardregel wird als `WikiPageUserPermission`-Datensatz mit `member_id: nil` gespeichert.
- Individuelle Benutzerberechtigungen:
  - Können für einzelne Projekt-Mitglieder hinzugefügt, editiert oder gelöscht werden.
  - Individuelle Regeln überschreiben die Standardregel.

## Datenbank

- Model: `WikiPageUserPermission` (Tabelle `wiki_page_user_permissions`)
  - Spalten: `member_id`, `wiki_page_id`, `level` (Integer)
- Migration: `db/migrate/001_create_wiki_page_user_permissions.rb`

# Credit

Das Plugin wurde als Aktualisierung von [edtsech/redmine_wiki_permissions](https://github.com/edtsech/redmine_wiki_permissions) entwickelt.
Der Großteil der Implementierung geht somit auf die Arbeit von [edtsech](https://github.com/edtsech) zurück.
