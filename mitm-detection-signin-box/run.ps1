using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

$date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# Step 1: Prepare a hash table with valid hosts
$validDomains = @{
    'https://login.microsoftonline.com/'            = $true
    'https://login.microsoft.com/'                  = $true
    'https://autologon.microsoftazuread-sso.com/'   = $true
    'https://login.windows.net'                     = $true
    'portal.azure.com'                              = $true
    '.logic.azure.com/'                             = $true
    '.office.com/'                                  = $true
    '.cloud/'                                       = $true
}

# Step 2: Extract the host from the incoming Referer header
$referer = ([uri]$request.headers.Referer).Host
# Write-Information "Referer: $referer"

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
    $ImageBytes = [Convert]::FromBase64String('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')
} 
 else {
    # Host is valid, return a transparent pixel
    $ImageBytes = [Convert]::FromBase64String('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAAYdEVYdFNvZnR3YXJlAFBhaW50Lk5FVCA1LjEuMWK1UgwAAAC2ZVhJZklJKgAIAAAABQAaAQUAAQAAAEoAAAAbAQUAAQAAAFIAAAAoAQMAAQAAAAIAAAAxAQIAEAAAAFoAAABphwQAAQAAAGoAAAAAAAAAYAAAAAEAAABgAAAAAQAAAFBhaW50Lk5FVCA1LjEuMQADAACQBwAEAAAAMDIzMAGgAwABAAAAAQAAAAWgBAABAAAAlAAAAAAAAAACAAEAAgAEAAAAUjk4AAIABwAEAAAAMDEwMAAAAAAbdNOU1AiGCwAAAA1JREFUGFdjYGBgYAAAAAUAAYoz4wAAAAAASUVORK5CYII=')
 }

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode  = [HttpStatusCode]::OK
    ContentType = 'image/png'
    Body        = $ImageBytes
})