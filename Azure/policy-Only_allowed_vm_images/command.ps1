$param = @{
    Name = "platform-image-policy"
    DisplayName = "Only allow a certain VM platform image"
    description = "This policy ensures that only UbuntuServer, Canonical is allowed from the image repository"
    #-Policy 'https://raw.githubusercontent.com/Azure/azure-policy/master/samples/Compute/platform-image-policy/azurepolicy.rules.json' `
    Policy = "./azurepolicy.rules.json"
    #-Parameter 'https://raw.githubusercontent.com/Azure/azure-policy/master/samples/Compute/platform-image-policy/azurepolicy.parameters.json' `
    Parameter = "./azurepolicy.parameters.json"
    Mode = 'All'
}

$definition = New-AzPolicyDefinition @param
$definition

$Subscription = Get-AzSubscription #-SubscriptionName 'Subscription01'
$assignment = New-AzPolicyAssignment -Name "AssignTest-$($param.name)" -Scope "/subscriptions/$($Subscription.Id)"  -PolicyDefinition $definition
$assignment