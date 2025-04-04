using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

$date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# Step 1: Prepare a hash table with valid hosts
$validDomains = @{
    'login.microsoftonline.com'            = $true
    'login.microsoft.com'                  = $true
    'autologon.microsoftazuread-sso.com'   = $true
    'login.windows.net'                    = $true
    'portal.azure.com'                     = $true
    '.logic.azure.com'                     = $true
    '.office.com'                          = $true
    '.microsoft'                           = $true
}

# Step 2: Extract the host from the incoming Referer header
if (-not $request.headers.Referer) {
    Write-Warning "Referer header is missing or empty at $date"
    $referer = ''
} else {
    $referer = ([uri]$request.headers.Referer).Host
    Write-Information "Referer: $referer"
}


# Step 3: Check for exact match
$exactMatch = $validDomains -contains $referer
# Write-Information "Exact match: $exactMatch"

# Step 4: Check for suffix match
$suffixMatch = $validDomains.Keys | Where-Object { $referer -match "$_" }
# Write-Information "Suffix match: $suffixMatch"

# Step 5: Check if the host is not valid
if (!$exactMatch -and !$suffixMatch) {
    # Host is not valid, return customized background
    Write-Warning "Possible mitm detected at $date from host: $referer"
    $imagePath = Join-Path -Path $env:HOME -ChildPath "site/wwwroot/img/signin_form_v2.png"
    #$imagePath = Join-Path -Path $env:HOME -ChildPath "site/wwwroot/img/anssicure.png"
    $imageBytes = [System.IO.File]::ReadAllBytes($imagePath)
} 
 else {
    # Host is valid, return a transparent pixel
    $imagePath = Join-Path -Path $env:HOME -ChildPath "site/wwwroot/img/pixel_transparent.png"
    $imageBytes = [System.IO.File]::ReadAllBytes($imagePath)
 }

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode  = [HttpStatusCode]::OK
    ContentType = 'image/png'
    Body        = $ImageBytes
})