# Quick example to set Storage Account Firewall CIDR and add exception for
#  AzureSerices, Metrics and Logging
#
# The script is using the function Get-AzureIPRangesAndServiceTags to retrieve the Json published by Microsoft

# Storage Account info
$StorageAccountName = 'ddiag75bb9b4b42d7f6e5'
$ResourceGroupName = 'myResourceGroup'

# Retrieve IP to add
# https://github.com/lazywinadmin/PowerShell/blob/master/AZURE-Get-AzureIPRangesAndServiceTags/Get-AzureIPRangesAndServiceTags.ps1
#$ips = "213.199.180.96/27","213.199.180.192/27","213.199.183.0/24"
$ips = ((Get-AzureIPRangesAndServiceTags |
    ConvertFrom-json).values |
    ?{$_.name -eq 'AzureActiveDirectory'}).properties.addressprefixes

# Enable Firewall on
Update-AzStorageAccountNetworkRuleSet -ResourceGroupName $resourceGroupName -Name $storageAccountName -DefaultAction Deny -Bypass AzureServices,Metrics,Logging

# Add Ips 
Add-AzStorageAccountNetworkRule -ResourceGroupName $resourceGroupName -AccountName $storageAccountName -IPAddressOrRange $ips

# Done :)