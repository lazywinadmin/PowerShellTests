# Install Az module
Install-Module Az -Verbose -Force -Scope CurrentUser

# Connect to Azure
Connect-AzAccount

# Retrieve subscription
Get-AzSUbscription

# Retrieve and update context
Get-AzContext

Set-AzCOntext -Subscription 'NameOfSub'
Select-AzSubscription -Subscription "Visual Studio Enterprise"

# Retrieve REsource Group
Get-AzResourceGroup

# Create resource group
New-AzResourceGroup -Name 'yada' -location 'West US'


# Retrieve vm
Get-AzVM

# Create a VM
New-AzVm `
    -ResourceGroupName "CrmTestingResourceGroup" `
    -Name "CrmUnitTests" `
    -Image "UbuntuLTS"

# Edit VM
$ResourceGroupName = "ExerciseResources"
$vm = Get-AzVM -Name MyVM -ResourceGroupName $ResourceGroupName
$vm.HardwareProfile.vmSize = "Standard_DS3_v2"

Update-AzVM -ResourceGroupName $ResourceGroupName  -VM $vm

# Create Ubuntu VM and open ssh port 22
New-AzVm -ResourceGroupName learn-fda2b16e-989d-49d5-9796-96e1e25370f1 -Name "testvm-eus-01" -Credential (Get-Credential) -Location "East US" -Image UbuntuLTS -OpenPorts 22

# Retrieve info such as the public ip
$vm = Get-AzVM -Name "testvm-eus-01" -ResourceGroupName learn-fda2b16e-989d-49d5-9796-96e1e25370f1
$vm | Get-AzPublicIpAddress
ssh bob@205.22.16.5
#exit
Get-AzResource -ResourceGroupName $vm.ResourceGroupName | ft




# Stop vm
$vm|stop-azvm
#or
Stop-AzVM -Name $vm.Name -ResourceGroup $vm.ResourceGroupName

# Delete vm (this does not delete dependent resource)
Remove-AzVM -Name $vm.Name -ResourceGroup $vm.ResourceGroupName


$vm | Remove-AzNetworkInterface –Force
Get-AzDisk -ResourceGroupName $vm.ResourceGroupName -DiskName $vm.StorageProfile.OSDisk.Name | Remove-AzDisk -Force
Get-AzVirtualNetwork -ResourceGroup $vm.ResourceGroupName | Remove-AzVirtualNetwork -Force
Get-AzPublicIpAddress -ResourceGroup $vm.ResourceGroupName | Remove-AzPublicIpAddress -Force


# Retrieve role assignements for all Resource Group
Get-AzResourceGroup | Get-AzRoleAssignment

