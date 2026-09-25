<#
.SYNOPSIS
    Smoke test for the WGHN Inventur API pages (50400/50401) using the Entra app (client credentials).

.DESCRIPTION
    1. Gets a token for the app registration.
    2. Resolves the company id by name.
    3. Lists the first worksheets (optionally filtered by store).
    4. Loads the first lines of one worksheet and counts all of its lines.

    Client ID and secret are read from environment variables, never stored in this file:
        $env:BusinessCentral__ClientId     = '...'
        $env:BusinessCentral__ClientSecret = '...'

    With -UseMyAccount the token is taken from the Azure CLI login of the current user instead
    (az login --tenant <tenantId>), e.g. for environments where the Entra app is not set up.

.EXAMPLE
    ./scripts/Test-InventoryApi.ps1
    ./scripts/Test-InventoryApi.ps1 -StoreNo F001
    ./scripts/Test-InventoryApi.ps1 -UseMyAccount -StoreNo F001
    ./scripts/Test-InventoryApi.ps1 -Environment Wintergerst-Gruppe -WorksheetSeqNo 123
#>
param(
    [string]$TenantId = '88e8ebd7-64b3-486e-9078-243dcd43eff9',
    [string]$Environment = 'Test',
    [string]$CompanyName = 'WGHN',
    [string]$StoreNo,
    [int]$WorksheetSeqNo,
    [switch]$UseMyAccount,
    [string]$ClientId = $env:BusinessCentral__ClientId,
    [string]$ClientSecret = $env:BusinessCentral__ClientSecret
)

$ErrorActionPreference = 'Stop'

if (-not $UseMyAccount -and (-not $ClientId -or -not $ClientSecret)) {
    throw 'Set $env:BusinessCentral__ClientId and $env:BusinessCentral__ClientSecret first, or use -UseMyAccount.'
}

function Invoke-Bc([string]$Uri) {
    $response = Invoke-RestMethod -Uri $Uri -Headers $script:Headers -SkipHttpErrorCheck -StatusCodeVariable status
    if ($status -ge 400) {
        $message = if ($response.error) { "$($response.error.code): $($response.error.message)" } else { $response }
        throw "HTTP $status for $Uri`n$message"
    }
    $response
}

# 1. Token
if ($UseMyAccount) {
    $accessToken = az account get-access-token --resource https://api.businesscentral.dynamics.com --tenant $TenantId --query accessToken -o tsv
    if ($LASTEXITCODE -ne 0 -or -not $accessToken) { throw "Azure CLI token failed. Run 'az login --tenant $TenantId' first." }
} else {
    $accessToken = (Invoke-RestMethod -Method Post -Uri "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token" -Body @{
        grant_type    = 'client_credentials'
        client_id     = $ClientId
        client_secret = $ClientSecret
        scope         = 'https://api.businesscentral.dynamics.com/.default'
    }).access_token
}
$script:Headers = @{ Authorization = "Bearer $accessToken"; Accept = 'application/json' }
Write-Host "Token OK ($Environment, $(if ($UseMyAccount) { 'user' } else { 'app' }))" -ForegroundColor Green

$root = "https://api.businesscentral.dynamics.com/v2.0/$TenantId/$Environment/api"

# 2. Company
$company = (Invoke-Bc "$root/v2.0/companies?`$filter=name eq '$CompanyName'").value | Select-Object -First 1
if (-not $company) { throw "Company '$CompanyName' not found in environment '$Environment'." }
Write-Host "Company '$CompanyName' = $($company.id)" -ForegroundColor Green

$base = "$root/wghn/inventory/v1.0/companies($($company.id))"

# 3. Worksheets
$filter = if ($StoreNo) { "&`$filter=storeNo eq '$StoreNo'" } else { '' }
$worksheets = (Invoke-Bc "$base/storeInventoryWorksheets?`$top=10$filter").value
Write-Host "`nWorksheets (max. 10):" -ForegroundColor Cyan
$worksheets | Format-Table worksheetSeqNo, description, storeNo, locationCode, worksheetType, noOfLines, lastModifiedDateTime -AutoSize

# 4. Lines
if (-not $WorksheetSeqNo) {
    $WorksheetSeqNo = ($worksheets | Where-Object noOfLines -gt 0 | Select-Object -First 1).worksheetSeqNo
}
if (-not $WorksheetSeqNo) {
    Write-Host 'No worksheet with lines found, skipping lines.' -ForegroundColor Yellow
    return
}

$lines = Invoke-Bc "$base/storeInventoryLines?`$filter=worksheetSeqNo eq $WorksheetSeqNo&`$top=5&`$count=true"
Write-Host "Lines of worksheet $WorksheetSeqNo (first 5 of $($lines.'@odata.count')):" -ForegroundColor Cyan
$lines.value | Format-Table lineNo, itemNo, description, barcode, unitOfMeasureCode, qtyCalculated, qtyPhysInventory, inventoryCountDateTime, deviceName -AutoSize
