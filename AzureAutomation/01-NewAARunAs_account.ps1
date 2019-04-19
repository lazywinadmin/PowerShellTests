<#
.SYNOPSIS
Script to grant access an Azure Automation account to a Specific Resource group.
.DESCRIPTION
Requirements: Resource Group and Azure Automation Account need to exist

This script will:
1. Import module Az.Automation and Connect to azure
2. Create a Self-Signed Certificate locally (required local administrator)
  pfx and cer files are placed in $env:temp
3. Create a azure active directory application
  Requires Application Developer Role, but works with Application administrator or GLOBAL ADMIN
4. Adds a credential to an existing application.
  Requires Application administrator or GLOBAL ADMIN
5. Create Service Principal
  Requires Application administrator or GLOBAL ADMIN
6. Assign 'Contributor' on the Resource Group specified
  Requires User Access Administrator or Owner.
7. Certificate information is placed on the AzureAutomation Account certificate asset
8. Create an Automation connection asset in the Automation account. This connection uses the service principal.
9. If $CreateClassicRunAsAccount parameter is $true, the same steps will be done.
  in addition you will need to upload the certificate, select Subscriptions -> Management Certificates
.Notes
Francois-Xavier Cat
@lazywinadmin
Change History
1.0 2019/04/18 Francois-Xavier Cat
    initial version based on https://docs.microsoft.com/en-us/azure/automation/manage-runas-account
#>

Function New-MSAzureAutomationAccount
{
#Requires -RunAsAdministrator

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [String] $ResourceGroup,

        [Parameter(Mandatory = $true)]
        [String] $AutomationAccountName,

        [Parameter(Mandatory = $true)]
        [String] $ApplicationDisplayName,

        [Parameter(Mandatory = $true)]
        [String] $SubscriptionId,

        [Parameter(Mandatory = $false)]
        [Boolean] $CreateClassicRunAsAccount=$true,

        [Parameter(Mandatory = $false)]
        [String] $SelfSignedCertPlainPassword=$true,

        [Parameter(Mandatory = $false)]
        [string] $EnterpriseCertPathForRunAsAccount,

        [Parameter(Mandatory = $false)]
        [String] $EnterpriseCertPlainPasswordForRunAsAccount,

        [Parameter(Mandatory = $false)]
        [String] $EnterpriseCertPathForClassicRunAsAccount,

        [Parameter(Mandatory = $false)]
        [String] $EnterpriseCertPlainPasswordForClassicRunAsAccount,

        [Parameter(Mandatory = $false)]
        [ValidateSet("AzureCloud", "AzureUSGovernment")]
        [string]$EnvironmentName = "AzureCloud",

        [Parameter(Mandatory = $false)]
        [int] $SelfSignedCertNoOfMonthsUntilExpired = 12,
        $CertifcateAssetName = "AzureRunAsCertificate",
        $ConnectionAssetName = "AzureRunAsConnection",
        $ConnectionTypeName = "AzureServicePrincipal",
        $ClassicRunAsAccountCertifcateAssetName = "AzureClassicRunAsCertificate",
        $ClassicRunAsAccountConnectionAssetName = "AzureClassicRunAsConnection",
        $ClassicRunAsAccountConnectionTypeName = "AzureClassicCertificate "
    )
    try{
        Write-Verbose -Message "Loading helper functions"
        function Create-SelfSignedCertificate
        {
            <#
            .SYNOPSIS
            Create a 12 months local SelfSigned certificate and export it locally
            #>
            [CmdletBinding()]
            PARAM(
                [string] $certificateName,
                [string] $selfSignedCertPlainPassword,
                [string] $certPath,
                [string] $certPathCer,
                [string] $selfSignedCertNoOfMonthsUntilExpired
            )
            $Cert = New-SelfSignedCertificate `
                -DnsName $certificateName `
                -CertStoreLocation cert:\LocalMachine\My `
                -KeyExportPolicy Exportable `
                -Provider "Microsoft Enhanced RSA and AES Cryptographic Provider" `
                -NotAfter (Get-Date).AddMonths($selfSignedCertNoOfMonthsUntilExpired) `
                -HashAlgorithm SHA256

            $CertPassword = ConvertTo-SecureString -String $selfSignedCertPlainPassword -AsPlainText -Force
            Export-PfxCertificate `
                -Cert ("Cert:\localmachine\my\" + $Cert.Thumbprint) `
                -FilePath $certPath `
                -Password $CertPassword `
                -Force -Verbose
            Export-Certificate `
                -Cert ("Cert:\localmachine\my\" + $Cert.Thumbprint) `
                -FilePath $certPathCer `
                -Type CERT -Verbose
        }

        function Create-ServicePrincipal {
            <#
            .SYNOPSIS
            Create an application Service Principal on the Subscription
            .DESCRIPTION

            #>
            [CmdletBinding()]
            PARAM(
                [System.Security.Cryptography.X509Certificates.X509Certificate2] $PfxCert,
                [string] $applicationDisplayName,
                $resourceGroup
            )
            $keyValue = [System.Convert]::ToBase64String($PfxCert.GetRawCertData())
            $keyId = (New-Guid).Guid

            # Create an Azure AD application, AD App Credential, AD ServicePrincipal

            # Requires Application Developer Role, but works with Application administrator or GLOBAL ADMIN

            $Application = New-AzureRmADApplication -DisplayName $ApplicationDisplayName `
                -HomePage ("http://" + $applicationDisplayName) `
                -IdentifierUris ("http://" + $keyId)
            
            # Requires Application administrator or GLOBAL ADMIN
            $ApplicationCredential = New-AzureRmADAppCredential -ApplicationId $Application.ApplicationId `
                -CertValue $keyValue `
                -StartDate $PfxCert.NotBefore `
                -EndDate $PfxCert.NotAfter

            # Requires Application administrator or GLOBAL ADMIN
            $ServicePrincipal = New-AzureRMADServicePrincipal -ApplicationId $Application.ApplicationId 
            $GetServicePrincipal = Get-AzureRmADServicePrincipal -ObjectId $ServicePrincipal.Id

            # Sleep here for a few seconds to allow the service principal application to become active (ordinarily takes a few seconds)
            Start-Sleep -Seconds 15

            # Requires User Access Administrator or Owner.
            #$NewRole = New-AzureRMRoleAssignment -RoleDefinitionName Contributor -ServicePrincipalName $Application.ApplicationId -ErrorAction SilentlyContinue
            $NewRole = New-AzureRMRoleAssignment -RoleDefinitionName Contributor `
                -ServicePrincipalName $Application.ApplicationId `
                -ErrorAction SilentlyContinue `
                -ResourceGroupName $resourceGroup

            # retry
            $Retries = 0
            While ($NewRole -eq $null -and $Retries -le 6) {
                Sleep -s 10
                #New-AzureRMRoleAssignment -RoleDefinitionName Contributor -ServicePrincipalName $Application.ApplicationId | Write-Verbose -ErrorAction SilentlyContinue
                New-AzureRMRoleAssignment -RoleDefinitionName Contributor `
                    -ServicePrincipalName $Application.ApplicationId `
                    -ResourceGroupName $resourceGroup -Verbose

                $NewRole = Get-AzureRMRoleAssignment `
                    -ServicePrincipalName $Application.ApplicationId `
                    -ErrorAction SilentlyContinue
                $Retries++
            }
            # Return information
            $Application.ApplicationId.ToString()
        }

        function Create-AutomationCertificateAsset
        {
            [CmdletBinding()]
            PARAM(
                [string] $resourceGroup,
                [string] $automationAccountName,
                [string] $certifcateAssetName,
                [string] $certPath,
                [string] $certPlainPassword,
                [Boolean] $Exportable
            )
            $CertPassword = ConvertTo-SecureString $certPlainPassword -AsPlainText -Force

            Remove-AzureRmAutomationCertificate -ResourceGroupName $resourceGroup `
                -AutomationAccountName $automationAccountName `
                -Name $certifcateAssetName `
                -ErrorAction SilentlyContinue

            New-AzureRmAutomationCertificate -ResourceGroupName $resourceGroup `
            -AutomationAccountName $automationAccountName `
            -Path $certPath `
            -Name $certifcateAssetName `
            -Password $CertPassword `
            -Exportable:$Exportable
        }

        function Create-AutomationConnectionAsset
        {
            [CmdletBinding()]
            PARAM(
                [string] $resourceGroup,
                [string] $automationAccountName,
                [string] $connectionAssetName,
                [string] $connectionTypeName,
                [System.Collections.Hashtable] $connectionFieldValues
            )
            Remove-AzureRmAutomationConnection `
                -ResourceGroupName $resourceGroup `
                -AutomationAccountName $automationAccountName `
                -Name $connectionAssetName `
                -Force `
                -ErrorAction SilentlyContinue
            New-AzureRmAutomationConnection `
                -ResourceGroupName $ResourceGroup `
                -AutomationAccountName $automationAccountName `
                -Name $connectionAssetName `
                -ConnectionTypeName $connectionTypeName `
                -ConnectionFieldValues $connectionFieldValues
        }

        <#
        Import-Module Az.Profile
        Import-Module AzureRM.Resources

        $AzureRMProfileVersion = (Get-Module AzureRM.Profile).Version
        if (!(($AzureRMProfileVersion.Major -ge 3 -and $AzureRMProfileVersion.Minor -ge 4) -or ($AzureRMProfileVersion.Major -gt 3))) {
            Write-Error -Message "Please install the latest Azure PowerShell and retry. Relevant doc url : https://docs.microsoft.com/powershell/azureps-cmdlets-docs/ "
            return
        }
        #>

        # To use the new Az modules to create your Run As accounts please uncomment the
        # following lines and ensure you comment out the previous 8 lines that import the AzureRM modules to avoid any issues. To learn about about using Az modules in your Automation Account see https://docs.microsoft.com/azure/automation/az-modules
        Write-Verbose -Message "Import module Az.Automation"
        Import-Module -Name Az.Automation
        Write-Verbose -Message "Enable RM Aliases"
        Enable-AzureRmAlias

        Write-Verbose -Message "Connect to Azure"
        Connect-AzureRmAccount -Environment $EnvironmentName 
        $Subscription = Select-AzureRmSubscription -SubscriptionId $SubscriptionId

        # Create a Run As account by using a service principal
        #$CertifcateAssetName = "FXAzureRunAsCertificate"
        #$ConnectionAssetName = "FXAzureRunAsConnection"
        #$ConnectionTypeName = "FXAzureServicePrincipal"

        if ($EnterpriseCertPathForRunAsAccount -and $EnterpriseCertPlainPasswordForRunAsAccount) {
            $PfxCertPathForRunAsAccount = $EnterpriseCertPathForRunAsAccount
            $PfxCertPlainPasswordForRunAsAccount = $EnterpriseCertPlainPasswordForRunAsAccount
        }
        else {
            $CertificateName = $AutomationAccountName + $CertifcateAssetName
            $PfxCertPathForRunAsAccount = Join-Path -Path $env:TEMP -ChildPath ($CertificateName + ".pfx")
            $PfxCertPlainPasswordForRunAsAccount = $SelfSignedCertPlainPassword
            $CerCertPathForRunAsAccount = Join-Path -Path $env:TEMP -ChildPath ($CertificateName + ".cer")
            Write-Verbose -Message "Create Self-Signed Certificate"
            Create-SelfSignedCertificate -certificateName $CertificateName `
                -selfSignedCertPlainPassword $PfxCertPlainPasswordForRunAsAccount `
                -CertPath $PfxCertPathForRunAsAccount `
                -CertPathCer $CerCertPathForRunAsAccount `
                -selfSignedCertNoOfMonthsUntilExpired $SelfSignedCertNoOfMonthsUntilExpired

                [string] $certificateName,
                [string] $selfSignedCertPlainPassword,
                [string] $certPath,
                [string] $certPathCer,
                [string] $selfSignedCertNoOfMonthsUntilExpired
        }

        # Create a service principal
        Write-Verbose -Message "Create a service principal"
        $PfxCert = New-Object -TypeName 'System.Security.Cryptography.X509Certificates.X509Certificate2' `
            -ArgumentList @($PfxCertPathForRunAsAccount, $PfxCertPlainPasswordForRunAsAccount)
        $ApplicationId = Create-ServicePrincipal -PfxCert $PfxCert `
            -applicationDisplayName $ApplicationDisplayName `
            -resourceGroup $ResourceGroup

        # Create the Automation certificate asset
        Write-Verbose -Message "Create the Automation certificate asset"
        Create-AutomationCertificateAsset -resourceGroup $ResourceGroup `
            -automationAccountName $AutomationAccountName `
            -certifcateAssetName $CertifcateAssetName `
            -certPath $PfxCertPathForRunAsAccount `
            -certPlainPassword $PfxCertPlainPasswordForRunAsAccount `
            -Exportable $true

        # Populate the ConnectionFieldValues
        Write-Verbose -Message "Populate the ConnectionFieldValues"
        $SubscriptionInfo = Get-AzureRmSubscription -SubscriptionId $SubscriptionId
        $TenantID = $SubscriptionInfo | Select-Object -Property TenantId -First 1
        $Thumbprint = $PfxCert.Thumbprint
        $ConnectionFieldValues = @{
            "ApplicationId" = $ApplicationId;
            "TenantId" = $TenantID.TenantId;
            "CertificateThumbprint" = $Thumbprint;
            "SubscriptionId" = $SubscriptionId
        }

        # Create an Automation connection asset named AzureRunAsConnection in the Automation account. This connection uses the service principal.
        Write-Verbose -Message "Create an Automation connection asset"
        Create-AutomationConnectionAsset -resourceGroup $ResourceGroup `
            -automationAccountName $AutomationAccountName `
            -connectionAssetName $ConnectionAssetName `
            -connectionTypeName $ConnectionTypeName `
            -connectionFieldValues $ConnectionFieldValues

        if ($CreateClassicRunAsAccount) {
            Write-Verbose -Message "Create classic runasaccount"
            # Create a Run As account by using a service principal
            #$ClassicRunAsAccountCertifcateAssetName = "AzureClassicRunAsCertificate"
            #$ClassicRunAsAccountConnectionAssetName = "AzureClassicRunAsConnection"
            #$ClassicRunAsAccountConnectionTypeName = "AzureClassicCertificate "
            $UploadMessage = "Please upload the .cer format of #CERT# to the Management store by following the steps below.$([Environment]::NewLine)`
            Log in to the Microsoft Azure portal (https://portal.azure.com) and select Subscriptions -> Management Certificates.$([Environment]::NewLine)`
            Then click Upload and upload the .cer format of #CERT#"

            if ($EnterpriseCertPathForClassicRunAsAccount -and $EnterpriseCertPlainPasswordForClassicRunAsAccount ) {
                $PfxCertPathForClassicRunAsAccount = $EnterpriseCertPathForClassicRunAsAccount
                $PfxCertPlainPasswordForClassicRunAsAccount = $EnterpriseCertPlainPasswordForClassicRunAsAccount
                $UploadMessage = $UploadMessage.Replace("#CERT#", $PfxCertPathForClassicRunAsAccount)
            }
            else {
                $ClassicRunAsAccountCertificateName = $AutomationAccountName + $ClassicRunAsAccountCertifcateAssetName
                $PfxCertPathForClassicRunAsAccount = Join-Path -Path $env:TEMP -ChildPath ($ClassicRunAsAccountCertificateName + ".pfx")
                $PfxCertPlainPasswordForClassicRunAsAccount = $SelfSignedCertPlainPassword
                $CerCertPathForClassicRunAsAccount = Join-Path -Path $env:TEMP -ChildPath ($ClassicRunAsAccountCertificateName + ".cer")
                $UploadMessage = $UploadMessage.Replace("#CERT#", $CerCertPathForClassicRunAsAccount)
                Write-Verbose -Message "Create self-signed certificate"
                Create-SelfSignedCertificate -certificateName $ClassicRunAsAccountCertificateName `
                    -selfSignedCertPlainPassword $PfxCertPlainPasswordForClassicRunAsAccount `
                    -CertPath $PfxCertPathForClassicRunAsAccount `
                    -CertPathCer $CerCertPathForClassicRunAsAccount `
                    -selfSignedCertNoOfMonthsUntilExpired $SelfSignedCertNoOfMonthsUntilExpired
            }

            # Create the Automation certificate asset
            Write-Verbose -Message "Create the Automation certificate asset"
            Create-AutomationCertificateAsset -resourceGroup $ResourceGroup `
                -automationaccountname $AutomationAccountName `
                -certifcateAssetName $ClassicRunAsAccountCertifcateAssetName `
                -certPath $PfxCertPathForClassicRunAsAccount
                -certPlainPassword $PfxCertPlainPasswordForClassicRunAsAccount
                -Exportable $false


            # Populate the ConnectionFieldValues
            $SubscriptionName = $subscription.Subscription.Name
            $ClassicRunAsAccountConnectionFieldValues = @{
                "SubscriptionName" = $SubscriptionName;
                "SubscriptionId" = $SubscriptionId;
                "CertificateAssetName" = $ClassicRunAsAccountCertifcateAssetName}

            # Create an Automation connection asset named AzureRunAsConnection in the Automation account. This connection uses the service principal.
            Write-Verbose -Message "Create Automation connection asset"
            Create-AutomationConnectionAsset -resourceGroup $ResourceGroup `
                -automationAccountName $AutomationAccountName `
                -connectionAssetName $ClassicRunAsAccountConnectionAssetName `
                -connectionTypeName $ClassicRunAsAccountConnectionTypeName `
                -connectionFieldValues $ClassicRunAsAccountConnectionFieldValues

            $UploadMessage
        }
    }#try
    catch{
        throw $_
    }
}


# Test
#  Created a TestNonRunAs2 RG and a AA account TestNonRunAs2 with Non-RunAs
#  No certificate under the AA Account
#  No RunAs Accounts
<#
$Param = @{
    ResourceGroup = 'TestNonRunAs2'
    AutomationAccountName='TestNonRunAs2'
    ApplicationDisplayName='AppTestNonRunAs2'
    SubscriptionId='<sub here>'
    CreateClassicRunAsAccount=$false
    Verbose=$true
}

New-MSAzureAutomationAccount @param

# After running
 * AA: we have a connection, a certificate, a runas account (no classic one)
 * Azure AD: Under "App Registration(preview)" the following AppTestNonRunAs2 has been created.
#>