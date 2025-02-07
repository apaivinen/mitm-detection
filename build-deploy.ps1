cls
# Azure configs
$resouceGroupName = "p-mgt-secautomation"
$FunctionAppName = "skbo-login-check"

# Deploy configs
# Define paths
$projectPath = "$PSScriptRoot"              # Root of the script
$publishFolder = "$projectPath\publish"     # build path for the code (for packaging)
$zipFolderPath = "$projectPath\package"     # Zip package location
$zipFilePath = "$zipFolderPath\functionapp.zip" # ZIP file path

# Clean up old publish folder
if (Test-Path $publishFolder) {
    Remove-Item $publishFolder -Recurse -Force
    new-item -ItemType directory -Path $publishFolder
}

write-host $projectPath
write-host $publishFolder

start-sleep -Seconds 1

# Copy project files to publish folder
Write-Host "Copying project files to publish folder..."
Copy-Item -Path "$projectPath\*" -Destination $publishFolder -Recurse -Force -Exclude 'package', 'publish'

# Remove old ZIP file if it exists
if (Test-Path $zipFilePath) {
    Remove-Item $zipFilePath -Force
}

# Ensure the package directory exists
if (-Not (Test-Path $zipFolderPath)) {
    Write-Host "Creating package directory: $zipFolderPath"
    New-Item -Path $zipFolderPath -ItemType Directory | Out-Null
}

# Create ZIP package
Write-Host "Creating ZIP package..."
Compress-Archive -Path "$publishFolder\*" -DestinationPath $zipFilePath -Force

Write-Host "ZIP package created successfully at: $zipFilePath"

# Deploying Azure Function App
Write-Host "Deploying Azure Function App..."

# Option 1: Using Azure CLI (recommended)
az functionapp deployment source config-zip --subscription ef061a44-d0e3-4049-917f-b4a6b70818e5 --resource-group $resouceGroupName --name $FunctionAppName --src $zipFilePath --build-remote true --debug

# OR

# Option 2: Using Azure Functions Core Tools
# Ensure Azure Functions Core Tools is installed and authenticated
# func azure functionapp publish $FunctionAppName --powershell --force
