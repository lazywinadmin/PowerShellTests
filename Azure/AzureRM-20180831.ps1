#https://docs.microsoft.com/en-us/azure/azure-resource-manager/powershell-azure-resource-manager


#Connect to azure
Connect-AzureRmAccount
# Retrieve Subscription
Get-AzureRmSubscription
# Set the context (If multiple subscription)
Set-AzureRmContext -SubscriptionName "Visual Studio Ultimate with MSDN"

# Create a new ResourceGroup for RM
New-AzureRmResourceGroup -Name FXDemo-rg -Location "South Central US"
# Retrieve the RG created
Get-AzureRmResourceGroup -ResourceGroupName TestRG1

# Retrieve region/location
Get-AzureRmLocation

# Get Roles
Get-AzureRmRoleDefinition
# Create Custom roles
New-AzureRmRoleDefinition
# Assign role to Group
$adgroup = New-AzureADGroup -DisplayName FXDemoContrib `
    -MailNickName FXDemoContrib
New-AzureRmRoleAssignment -ObjectId $adgroup.Id `
    -ResourceGroupName FXDemo-rg `
    -RoleDefinitionName "Virtual Machine Contributor"

# Azure Policies
(Get-AzureRmPolicyDefinition).Properties


# Azure VM
New-AzureRmVm -ResourceGroupName FXDemo-rg `
     -Name "myVM" `
     -Location "East US" `
     -VirtualNetworkName "myVnet" `
     -SubnetName "mySubnet" `
     -SecurityGroupName "myNetworkSecurityGroup" `
     -PublicIpAddressName "myPublicIpAddress" `
     -OpenPorts 80,3389

#Tagging

Set-AzureRmResourceGroup -Name FXDemo-rg -Tag @{ Dept="IT"; Environment="Test" }