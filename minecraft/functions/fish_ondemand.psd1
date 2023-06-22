# Function app and storage account names must be unique.
$randomInt = Get-Random -Maximum 9999
$resourceGroupName = "minecraft-resources"
$region = ""
$storageName = "vmpowersa$randomInt"
$functionAppName = "vmpowerfunc$randomInt"

# Create an azure storage account
az storage account create `
    --name "$storageName" `
    --location "$region" `
    --resource-group "$resourceGroupName" `
    --sku "Standard_LRS" `
    --kind "StorageV2"

# Create a Function App
az functionapp create `
    --name "$functionAppName" `
    --storage-account "$storageName" `
    --consumption-plan-location "$region" `
    --resource-group "$resourceGroupName" `
    --os-type "Windows" `
    --runtime "powershell" `
    --runtime-version "7.2" `
    --functions-version "4"
