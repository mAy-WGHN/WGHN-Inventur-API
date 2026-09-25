// Read-only API for the external Inventur-API: store inventory worksheet lines.
// GET /api/wghn/inventory/v1.0/companies({companyId})/storeInventoryLines?$filter=worksheetSeqNo eq 123
// Up to ~13,000 lines per worksheet: the client must follow @odata.nextLink.
page 50401 "WGHN Inv. Line API"
{
    PageType = API;
    APIPublisher = 'wghn';
    APIGroup = 'inventory';
    APIVersion = 'v1.0';
    EntityName = 'storeInventoryLine';
    EntitySetName = 'storeInventoryLines';
    EntityCaption = 'Store Inventory Line';
    EntitySetCaption = 'Store Inventory Lines';
    Caption = 'WGHN Inventory Line API';
    SourceTable = "LSC Store Inventory Line";
    ODataKeyFields = SystemId;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    DataAccessIntent = ReadOnly;
    Extensible = false;

    layout
    {
        area(Content)
        {
            repeater(Records)
            {
                field(id; Rec.SystemId) { Caption = 'Id'; }
                field(worksheetSeqNo; Rec.WorksheetSeqNo) { Caption = 'Worksheet Seq. No.'; }
                field(lineNo; Rec."Line No.") { Caption = 'Line No.'; }
                field(itemNo; Rec."Item No.") { Caption = 'Item No.'; }
                field(variantCode; Rec."Variant Code") { Caption = 'Variant Code'; }
                field(description; Rec.Description) { Caption = 'Description'; }
                field(barcode; Rec.Barcode) { Caption = 'Barcode'; }
                field(unitOfMeasureCode; Rec."Unit of Measure Code") { Caption = 'Unit of Measure Code'; }
                field(qtyPerUnitOfMeasure; Rec."Qty. per Unit of Measure") { Caption = 'Qty. per Unit of Measure'; }
                field(qtyCalculated; Rec."Qty. (Calculated)") { Caption = 'Qty. (Calculated)'; }
                field(qtyPhysInventory; Rec."Qty. (Phys. Inventory)") { Caption = 'Qty. (Phys. Inventory)'; }
                field(quantity; Rec.Quantity) { Caption = 'Quantity'; }
                field(quantityBase; Rec."Quantity (Base)") { Caption = 'Quantity (Base)'; }
                field(postingDate; Rec."Posting Date") { Caption = 'Posting Date'; }
                field(entryType; Rec."Entry Type") { Caption = 'Entry Type'; }
                field(reasonCode; Rec."Reason Code") { Caption = 'Reason Code'; }
                field(areaCode; Rec."Area Code") { Caption = 'Area Code'; }
                field(sectionCode; Rec."Section Code") { Caption = 'Section Code'; }
                field(shelfCode; Rec."Shelf Code") { Caption = 'Shelf Code'; }
                field(serialNo; Rec."Serial No.") { Caption = 'Serial No.'; }
                field(lotNo; Rec."Lot No.") { Caption = 'Lot No.'; }
                field(expirationDate; Rec."Expiration Date") { Caption = 'Expiration Date'; }
                field(scanDateTime; Rec."Scan DateTime") { Caption = 'Scan Date Time'; }
                field(retailUser; Rec."Retail User") { Caption = 'Retail User'; }
                field(staffId; Rec."Staff ID") { Caption = 'Staff ID'; }
                // WGHN fields (tableextension 50026 "WGHN Store Invt Line")
                field(inventoryCountDateTime; Rec."WGHN Inventory Count DateTime") { Caption = 'Inventory Count Date Time'; }
                field(originalInventoryCount; Rec."WGHN Original Inventory Count") { Caption = 'Original Inventory Count'; }
                field(deviceName; Rec."Device Name") { Caption = 'Device Name'; }
                field(lastDatetimeModified; Rec."Last Datetime Modified") { Caption = 'Last Datetime Modified'; }
                field(lastModifiedDateTime; Rec.SystemModifiedAt) { Caption = 'Last Modified Date Time'; }
            }
        }
    }
}
