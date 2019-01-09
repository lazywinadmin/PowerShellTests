#https://docs.microsoft.com/en-us/azure/azure-resource-manager/powershell-azure-resource-manager
Get-Module -ListAvailable -Name AzureRm.Resources | Select-Object -prop Version

# Login to Azure
#Login-AzureRmAccount


# Retrieve Subscription
Get-AzureRmSubscription

# Set the context (If multiple subscription)
Set-AzureRmContext -SubscriptionName "Visual Studio Ultimate with MSDN"

# Create a new ResourceGroup for RM
New-AzureRmResourceGroup -Name TestRG1 -Location "South Central US"
# Retrieve the RG created
Get-AzureRmResourceGroup -ResourceGroupName TestRG1
Get-AzureRmResourceGroup

# Retrieve my current RM Storage Account(s)
Get-AzureRmStorageAccount

# Retrieve my current RM Resources
Get-AzureRmResource

# Create RM Storage Account
$MyStorageAccount = 'fxstorageaccount'
New-AzureRmStorageAccount -ResourceGroupName TestRG1 -AccountName $MyStorageAccount -Type "Standard_LRS" -Location "South Central US"
# Retrieve it
Get-AzureRmResource -ResourceName $MyStorageAccount -ResourceGroupName TestRG1
# Set Tag and assign account to RG
Set-AzureRmResource -Tag @{ Dept="IT"; Environment="Test" } -ResourceName $MyStorageAccount -ResourceGroupName TestRG1 -ResourceType Microsoft.Storage/storageAccounts

# Retrieve Tags 
$tags = (Get-AzureRmResource -ResourceName $MyStorageAccount -ResourceGroupName TestRG1).Tags

# Append Status
$tags += @{Status="Approved"}

# Set value
Set-AzureRmResource -Tag $tags -ResourceName $MyStorageAccount -ResourceGroupName TestRG1 -ResourceType Microsoft.Storage/storageAccounts

# REtrieve resources
Find-AzureRmResource -ResourceNameContains $MyStorageAccount
Find-AzureRmResource -ResourceGroupNameContains TestRG1
Find-AzureRmResource -TagName Dept -TagValue IT
Find-AzureRmResource -ResourceType Microsoft.Storage/storageAccounts

# to retrieve GUID
$webappID = (Get-AzureRmResource -ResourceGroupName TestRG1 -ResourceName exampleSite).ResourceId

# making sure our critical resource dont get deleted
New-AzureRmResourceLock -LockLevel CanNotDelete -LockName LockStorage -ResourceName $MyStorageAccount -ResourceType Microsoft.Storage/storageAccounts -ResourceGroupName TestRG1

# Trying to remove
Remove-AzureRmResourceLock -LockName LockStorage -ResourceName $MyStorageAccount -ResourceType Microsoft.Storage/storageAccounts -ResourceGroupName TestRG1



