# WGHN Inventur API

Business-Central-Erweiterung (AL), die die LS-Central-Inventurbuchblätter als **lesende OData-v4-API** bereitstellt. Abnehmer ist die externe Inventur-API (`BcODataClient`), die bisher die Buchblattdaten per xlsx-Import („Lagerbestandsjournal“) übernommen hat.

| | |
|---|---|
| **Publisher** | MAy |
| **BC / Runtime** | Application 27.0, Runtime 15.0 (läuft auch auf BC 28) |
| **Target** | Cloud (SaaS), manuelle Installation als PTE |
| **ID-Bereich** | 50400–50499 |
| **Abhängigkeiten** | LS Central ≥ 27.0, WGHN (JM IT) ≥ 27.0.0.103 |

## Endpunkte

Basis-URL:

```
https://api.businesscentral.dynamics.com/v2.0/{tenantId}/{environment}/api/wghn/inventory/v1.0/companies({companyId})/
```

Die `companyId` liefert `GET .../api/v2.0/companies`.

| Entity-Set | Objekt | Quelltabelle | Typische Abfrage |
|---|---|---|---|
| `storeInventoryWorksheets` | Page 50400 „WGHN Inv. Worksheet API“ | LSC Store Inventory Worksheet | `?$filter=storeNo eq 'F001'` |
| `storeInventoryLines` | Page 50401 „WGHN Inv. Line API“ | LSC Store Inventory Line | `?$filter=worksheetSeqNo eq 123` |

Die Zeilen lassen sich auch über den Kopf laden: `storeInventoryWorksheets({id})?$expand=storeInventoryLines`.

Beide Seiten sind **nur lesend** (`Editable = false`, kein Insert/Modify/Delete) und lesen von der Lesekopie der Datenbank (`DataAccessIntent = ReadOnly`), d. h. Änderungen können wenige Sekunden verzögert erscheinen. Schlüssel ist jeweils `id` (`SystemId`).

### Wichtige Felder

**Kopf:** `worksheetSeqNo`, `description`, `storeNo`, `locationCode`, `reasonCode`, `worksheetType`, `defaultUoM`, `useArea`, `quantityMethod`, `typeOfEntering` (Eingabeart), `countingPeriod`, `nextCount`, `cycleCount`, `noOfLines`, `lastModifiedDateTime`

**Zeilen:** `worksheetSeqNo`, `lineNo`, `itemNo`, `variantCode`, `description`, `barcode`, `unitOfMeasureCode`, `qtyPerUnitOfMeasure`, `qtyCalculated` (Soll-/Buchbestand), `qtyPhysInventory`, `quantity`, `quantityBase`, `postingDate`, `entryType`, `reasonCode`, `areaCode`, `sectionCode`, `shelfCode`, `serialNo`, `lotNo`, `expirationDate`, `scanDateTime`, `retailUser`, `staffId`, `lastModifiedDateTime`

WGHN-Felder aus `tableextension 50026 "WGHN Store Invt Line"`: `inventoryCountDateTime`, `originalInventoryCount`, `deviceName`, `lastDatetimeModified`

### Hinweise für Clients

- **Seitenweise abrufen:** Buchblätter haben bis zu ca. 13.000 Zeilen. Der Client muss `@odata.nextLink` folgen.
- **Kein Status am Kopf:** Die LS-Tabelle hat kein Statusfeld. Gefiltert wird nach `storeNo` und `worksheetType`.
- **`qtyCalculated` ist gespeichert**, kein berechnetes Feld: Der Wert bleibt auf dem Stand der Zeilenerzeugung.
- **Änderungsabgleich über die Zeilen:** `lastModifiedDateTime` am Kopf ändert sich nicht, wenn sich nur Zeilen ändern.
- **Enum-/Optionsfelder** werden als Text geliefert (z. B. `worksheetType`, `entryType`).

## Berechtigungen

Die Erweiterung bringt den Berechtigungssatz **WGHN INV API** (50400) mit: Lesen auf beide Tabellen, Ausführen der beiden Seiten.

Zuweisung in BC unter **Microsoft Entra-Anwendungen** → Anwendung der Inventur-API → **Benutzerberechtigungssätze**. Prüfen lässt sich der Zugriff über **Effektive Berechtigungen**.

## Entwicklung

1. Repo klonen und in VS Code mit der AL-Erweiterung öffnen.
2. `.vscode/launch.json` für die eigene Sandbox anlegen (wird nicht versioniert).
3. **AL: Download Symbols** ausführen (`.alpackages/` wird nicht versioniert).
4. Bauen mit **Strg+Umschalt+B** → erzeugt `MAy_WGHN Inventur API_<version>.app` im Projektordner.

CodeCop und UICop sind über `.vscode/settings.json` und `_BC.ruleset.json` aktiv und müssen fehlerfrei sein.

### Konventionen

- Dateinamen: `<ObjektTyp>.<ObjektId>.<ObjektName>.al`, abgelegt unter `src/<objekttyp>/`
- Objektpräfix: `WGHN `
- API-Feldnamen in camelCase

## Auslieferung

1. `version` in `app.json` erhöhen (BC nimmt keine bereits installierte Version erneut an).
2. `.app` bauen.
3. In BC über **Erweiterungsverwaltung → Hochladen** installieren.
4. Beim ersten Mal: Berechtigungssatz **WGHN INV API** der Entra-Anwendung zuweisen.

Vor der Installation in einer neuen Umgebung prüfen:

- **ID-Bereich frei?** In „Alle Objekte mit Beschriftung“ nach `50400..50499` filtern. Der Bereich 502xx ist im Mandanten bereits durch das „JM POS Module“ belegt. Eine Kollision fällt erst beim Installieren auf, nicht beim Kompilieren.
- **Abhängigkeiten installiert?** LS Central ≥ 27.0 und WGHN ≥ 27.0.0.103.
