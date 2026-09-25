// Assign to the Entra app registration of the external Inventur-API (read only).
permissionset 50400 "WGHN INV API"
{
    Assignable = true;
    Caption = 'WGHN Inventur API (lesend)';

    Permissions =
        tabledata "LSC Store Inventory Worksheet" = R,
        tabledata "LSC Store Inventory Line" = R,
        page "WGHN Inv. Worksheet API" = X,
        page "WGHN Inv. Line API" = X;
}
