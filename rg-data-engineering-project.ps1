# Define variables
$rgName = "rg-data-engineering-project"
$locName = "ukwest"  # Change the location as needed

# Create Resource Group
New-AzResourceGroup -Name $rgName -Location $locName

# Create Azure Data Factory
$adfName = "adf-data-engineering-project-$(Get-Random)"
New-AzDataFactoryV2 -ResourceGroupName $rgName -Name $adfName -Location $locName

# Create Azure Databricks Workspace
$databricksName = "databricks-data-engineering"
New-AzDatabricksWorkspace -ResourceGroupName $rgName -Name $databricksName -Location $locName -Sku "Standard"

# Create Key Vault (ensure the name meets the pattern requirements)
$keyVaultName = "kv-dataengproj" + $(Get-Random -Maximum 10000) # Change the keyvault name as needed
New-AzKeyVault -ResourceGroupName $rgName -VaultName $keyVaultName -Location $locName -Sku Standard

# Create Storage Account
$storageAccountName = "stgdataengineeringproj"  # Change the storage account name as needed to something unique
New-AzStorageAccount -ResourceGroupName $rgName -Name $storageAccountName -Location $locName -SkuName Standard_LRS -Kind StorageV2

# Create Synapse Workspace
$synapseWorkspaceName = "synapse-data-engineering"
$synapseAdminLogin = "adminuser"
$synapseAdminPassword = ConvertTo-SecureString "Changeme40!!" -AsPlainText -Force  # Change the password as needed
$storageAccount = Get-AzStorageAccount -ResourceGroupName $rgName -Name $storageAccountName
$storageKey = (Get-AzStorageAccountKey -ResourceGroupName $rgName -Name $storageAccountName)[0].Value
$dataLakeStorageAccountUrl = "https://$storageAccountName.dfs.core.windows.net"

# Correct the issue with SqlAdministratorLoginCredential parameter
$adminCredential = New-Object System.Management.Automation.PSCredential ($synapseAdminLogin, $synapseAdminPassword)

New-AzSynapseWorkspace -ResourceGroupName $rgName -Name $synapseWorkspaceName -Location $locName -DefaultDataLakeStorageAccountName $storageAccountName -DefaultDataLakeStorageFilesystem "default" -SqlAdministratorLoginCredential $adminCredential

# Output the resource group and services
Write-Output "Resource Group '$rgName' created with the following services:"
Write-Output " - Azure Data Factory: $adfName"
Write-Output " - Azure Databricks: $databricksName"
Write-Output " - Azure Key Vault: $keyVaultName"
Write-Output " - Azure Synapse: $synapseWorkspaceName"
Write-Output " - Azure Storage Account: $storageAccountName"
