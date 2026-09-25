# Offene Punkte

Stand: 25.09.2026

## 1. Test in der Sandbox „Test“

Die Erweiterung ist in der Sandbox veröffentlicht. Der Aufruf mit der App-Registrierung scheitert dort mit `401 Authentication_InvalidCredentials`: Das Token wird ausgestellt, aber die App ist in der Sandbox nicht als Microsoft Entra-Anwendung eingerichtet. Mein Zugriff zum Einrichten besteht nur für die Produktion.

- [ ] Seiten mit dem eigenen Konto testen:
      ```powershell
      az login --tenant 88e8ebd7-64b3-486e-9078-243dcd43eff9
      ./scripts/Test-InventoryApi.ps1 -UseMyAccount -StoreNo 0010
      ```
      Scheitert die Anmeldung mit `AADSTS65002` / „consent“, ist die Azure CLI für Business Central nicht freigegeben → anderen Weg suchen.
- [ ] Prüfen, ob `@odata.count` der Zeilen zu `noOfLines` im Kopf passt.
- [ ] Prüfen, welches Benutzerfeld tatsächlich gefüllt ist: `retailUser` oder `staffId`.

## 2. App-Registrierung testen – mit dem BC-Team klären

Entscheiden, welcher Weg gilt:

- [ ] **A: BC-Team richtet die App in der Sandbox ein**
      1. Sandbox „Test“ → „Microsoft Entra-Anwendungen“
      2. Client-ID der Inventur-API eintragen (bzw. vorhandenen Eintrag öffnen), Status **Aktiviert**
      3. Unter „Benutzerberechtigungssätze“ **WGHN INV API** zuweisen
      4. Bei `403` auf `companies`: zusätzlich **D365 READ**
- [ ] **B: Erweiterung direkt in Produktion („Wintergerst-Gruppe“) installieren**
      - Vorher in „Alle Objekte mit Beschriftung“ prüfen, ob `50400..50499` frei ist (502xx ist durch das „JM POS Module“ belegt)
      - Abhängigkeiten prüfen: LS Central ≥ 27.0, WGHN ≥ 27.0.0.103
      - Test mit `./scripts/Test-InventoryApi.ps1 -Environment Wintergerst-Gruppe`

## 3. Produktivsetzung

- [ ] `version` in `app.json` erhöhen, `.app` bauen, über die Erweiterungsverwaltung hochladen
- [ ] Berechtigungssatz **WGHN INV API** der Entra-Anwendung der Inventur-API zuweisen (derzeit hat sie **SUPER S2S**, darüber würde es auch ohne funktionieren)

## 4. Umbau der Inventur-API (`BcODataClient`)

- [ ] Basis-URL auf `/api/wghn/inventory/v1.0/companies({companyId})/` umstellen
- [ ] Firmen-ID über `GET /api/v2.0/companies?$filter=name eq 'WGHN'` ermitteln
- [ ] DTOs auf camelCase-Feldnamen umstellen (siehe README)
- [ ] `@odata.nextLink` folgen (bis ca. 13.000 Zeilen pro Buchblatt)
- [ ] Änderungsabgleich über `lastModifiedDateTime` der **Zeilen** (der Kopf ändert sich bei Zeilenänderungen nicht)
- [ ] xlsx-Import ablösen, sobald die API stabil läuft

## 5. Fragen an das BC-Team

- [ ] Wer legt die Buchblätter an? (Annahme: weiterhin in BC, wir lesen nur)
- [ ] Welche Buchblätter sollen wir sehen? Nur bestimmte `worksheetType`-Werte? Es gibt **kein Statusfeld** am Kopf – wie erkennen wir offene/abgeschlossene Buchblätter?
- [ ] Was steuert „Eingabeart“ (`typeOfEntering`) genau?
- [ ] Wird `qtyCalculated` nur beim Erzeugen der Zeilen („Bestand berechnen“) gesetzt? (Laut Symbolen ein gespeichertes Feld, kein FlowField.)

## 6. Später

- [ ] **SUPER S2S** der Inventur-API durch schmale Berechtigungssätze ersetzen (WGHN INV API + Lesesatz für die MigSync-Tabellen). Entscheidung liegt beim BC-Team.
- [ ] Rückschreiben der Zählmengen nach BC (bewusst zurückgestellt; bräuchte eine zusätzliche, schreibende API-Seite)
