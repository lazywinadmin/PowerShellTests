# https://stackoverflow.com/questions/49861955/list-of-all-azure-resource-types-in-azure
#   https://docs.microsoft.com/en-us/rest/api/resources/providers/list
#   https://docs.microsoft.com/en-us/rest/api/resources/providers/listattenantscope
#   https://docs.microsoft.com/en-us/azure/templates/microsoft.devices/iothub-allversions

[CmdletBinding()]
param(
    $SubscriptionId='8f2a8176-f66f-420c-8fce-a797ac7cde89',
    $PolicyDefinitionId='/subscriptions/8f2a8176-f66f-420c-8fce-a797ac7cde89/providers/Microsoft.Authorization/policyDefinitions/8c2f213e-decf-4016-a59e-5e7ce9903075',
    $PolicyAssignmentScope='/subscriptions/8f2a8176-f66f-420c-8fce-a797ac7cde89/resourceGroups/LogicApp/',
    $AllowedService= @('Microsoft.Compute','Microsoft.Storage','Microsoft.Network')
)
try{
    Write-Verbose -Message "Set Context to Subscription id '$SubscriptionId'"
    Set-AzContext -Subscription $SubscriptionId

    # Define allowed services
    

    # Retrieve Providers
    Write-Verbose -Message "Retrieving Providers..."
    $SubProviders = Get-AzResourceProvider -ListAvailable

    # Retrieve All Policy Aliases
    Write-Verbose -Message "Retrieving all Policy Aliases..."
    $AllAliases = Get-AzPolicyAlias -ListAvailable


    $SubResourceTypes = $SubProviders | Sort-Object -property ProviderNamespace |%{
        $CurrentNamespace = $_.ProviderNamespace
        
        # Resource type from providers
        $_.ResourceTypes |
            ForEach-Object{"$CurrentNamespace/$($_.ResourceTypeName)"}
        # Resource type from aliases
        $AllAliases|
            Where-Object{$_.Namespace -eq $CurrentNamespace}|
            ForEach-Object{"$($_.Namespace)/$($_.ResourceType)"}
    }

    # Retrieve session token
    $currentAzureContext = Get-AzContext
    $azureRmProfile = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile;
    $profileClient = New-Object Microsoft.Azure.Commands.ResourceManager.Common.RMProfileClient($azureRmProfile);
    $token=$profileClient.AcquireAccessToken($currentAzureContext.Subscription.TenantId).AccessToken;

    $authHeader = @{
        'Content-type' = 'application/json'
        'Authorization'="Bearer $token"
        #'ExpiresOn'=$accessToken.expires_in
    }

    #Providers - Tenant level
    Write-Verbose -Message "Retrieving Resource Providers on the Tenant level..."
    $uri = "https://management.azure.com/providers?`$expand=resourceTypes/aliases&api-version=2019-10-01"
    $result = Invoke-RestMethod -Method Get -Uri $uri -Headers $authHeader
    $TenantResourceTypes = $result.value |
        ForEach-Object {
            $ResourceProvider = $_.namespace
            $_.resourceTypes|
                ForEach-Object{"$ResourceProvider/$($_.resourceType)"}
        }   

    Write-Verbose -Message "Finalizing resource type list..."
    $finalList = ($TenantResourceTypes + $SubResourceTypes)|
        Select-Object -Unique

    # $finalList=$finalList | %{
    #     $splitted=$_ -split '\/'
    #     if($splitted.count -gt 2){
    #         "$($splitted[0..1] -join '/')/*"
    #     }
    #     else{$splitted -join '/'}
    # }|select -Unique

    # Create Policy Assingment
    Write-Verbose -Message "Retrieving Policy Definition..."
    $def = Get-AzPolicyDefinition -Id $PolicyDefinitionId

    Write-Verbose -Message "Creating Policy Assignment..."
    New-AzPolicyAssignment `
        -Name 'testing-allowed-resource' `
        -Scope $PolicyAssignmentScope `
        -listOfResourceTypesAllowed $finalList `
        -PolicyDefinition $def

    #Remove-AzPolicyAssignment -Id $NewAssign


    # Still missing
    # Microsoft.Devices
    #   IotHubs/certificates
    # Microsoft.Network
    #   virtualNetworks/taggedTrafficConsumers
    # Microsoft.OperationalInsight
    #   workspaces/views
    # Microsoft.Web
    #   a bunch
    #   hostingenvironments/metricdefinitions
    #   hostingenvironments/metrics
    #($result.value|?{$_.namespace -match 'Microsoft.Network'}|select -expand resourceTypes).resourceType|sort

    #https://management.azure.com/providers/Microsoft.Authorization/providerOperations?api-version=2018-01-01-preview&$expand=resourceTypes#


}catch{
    throw $_
}