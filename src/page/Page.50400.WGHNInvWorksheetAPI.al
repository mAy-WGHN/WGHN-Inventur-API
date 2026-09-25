// Read-only API for the external Inventur-API: one record per store inventory worksheet.
// GET /api/wghn/inventory/v1.0/companies({companyId})/storeInventoryWorksheets?$filter=storeNo eq 'X'
// Lines via $expand=storeInventoryLines or the separate entity set of page 50401.
page 50400 "WGHN Inv. Worksheet API"
{
    PageType = API;
    APIPublisher = 'wghn';
    APIGroup = 'inventory';
    APIVersion = 'v1.0';
    EntityName = 'storeInventoryWorksheet';
    EntitySetName = 'storeInventoryWorksheets';
    EntityCaption = 'Store Inventory Worksheet';
    EntitySetCaption = 'Store Inventory Worksheets';
    Caption = 'WGHN Inventory Worksheet API';
    SourceTable = "LSC Store Inventory Worksheet";
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
                field(description; Rec.Description) { Caption = 'Description'; }
                field(storeNo; Rec."Store No.") { Caption = 'Store No.'; }
                field(locationCode; Rec."Location Code") { Caption = 'Location Code'; }
                field(reasonCode; Rec."Reason Code") { Caption = 'Reason Code'; }
                field(worksheetType; Rec."Worksheet Type") { Caption = 'Worksheet Type'; }
                field(defaultUoM; Rec."Default UoM") { Caption = 'Default UoM'; }
                field(useArea; Rec."Use Area") { Caption = 'Use Area'; }
                field(quantityMethod; Rec."Quantity Method") { Caption = 'Quantity Method'; }
                field(typeOfEntering; Rec."Type of Entering") { Caption = 'Type of Entering'; }
                field(countingPeriod; Rec."Counting Period") { Caption = 'Counting Period'; }
                field(nextCount; Rec."Next count") { Caption = 'Next Count'; }
                field(cycleCount; Rec."Cycle count") { Caption = 'Cycle Count'; }
                field(noOfLines; Rec."No. of Lines") { Caption = 'No. of Lines'; }
                field(lastModifiedDateTime; Rec.SystemModifiedAt) { Caption = 'Last Modified Date Time'; }
            }
            part(storeInventoryLines; "WGHN Inv. Line API")
            {
                Caption = 'Store Inventory Lines';
                EntityName = 'storeInventoryLine';
                EntitySetName = 'storeInventoryLines';
                SubPageLink = WorksheetSeqNo = field(WorksheetSeqNo);
            }
        }
    }
}
