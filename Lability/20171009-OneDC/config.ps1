Configuration BasicServerClient {
    param (
        [ValidateNotNull()]
        [PSCredential]$Credential = (Get-Credential -Credential 'Administrator')
    )

    # Remember, these modules are required on the host as that's where the .MOFs are compiled,
    # and the modules are also copied across to our VMs as that's where they are applied
    #Import-DscResource -ModuleName PSDesiredStateConfiguration
    
    Write-Verbose 'Import DSC Resources'
    Write-Verbose 'Import DSC Resources - xComputerManagement'
    Import-DscResource -ModuleName xComputerManagement
    Write-Verbose 'Import DSC Resources - xNetworking'
    Import-DscResource -ModuleName xNetworking
    Write-Verbose 'Import DSC Resources - xActiveDirectory'
    Import-DscResource -ModuleName xActiveDirectory
    Write-Verbose 'Import DSC Resources - xDHCPServer'
    Import-DscResource -ModuleName xDHCPServer
    Write-Verbose 'Import DSC Resources - xDnsServer'
    Import-DscResource -ModuleName xDnsServer
    Write-Verbose 'Import DSC Resources - xPSDesiredStateConfiguration'
    #Import-DscResource -ModuleName xPSDesiredStateConfiguration
    Import-DscResource -ModuleName @{ModuleName='xPSDesiredStateConfiguration';RequiredVersion='7.0.0.0'}  
    #
    # ALL nodes
    #
    Write-Verbose 'Processing: All nodes'
    Node $AllNodes.Where({ $true }).NodeName {

        Write-Verbose "Processing:   $($node.NodeName)"

        # LCM settings
        LocalConfigurationManager {
            RebootNodeIfNeeded   = $true
            AllowModuleOverwrite = $true
            ConfigurationMode    = 'ApplyOnly'
            #CertificateID       = $node.Thumbprint
        }
    }

    node $AllNodes.Where({$_.Role -in 'DC'}).NodeName {
        ## Flip credential into username@domain.com
        $domainCredential = New-Object System.Management.Automation.PSCredential("$($Credential.UserName)@$($node.DomainName)", $Credential.Password);

        xComputer 'Computer_Hostname' {
            Name = $node.NodeName;
        }

        ## Hack to fix DependsOn with hypens "bug" :(
        foreach ($feature in @(
                'AD-Domain-Services',
                'GPMC',
                'RSAT-AD-Tools'
            )) {
            xWindowsFeature $feature.Replace('-','') {
                Ensure = 'Present';
                Name = $feature;
                IncludeAllSubFeature = $true;
                DependsOn = '[xComputer]Computer_Hostname';
            }
        }
        
        xADDomain 'ADDomain_corp_contoso_com' {
            DomainName = $node.DomainName;
            SafemodeAdministratorPassword = $Credential;
            DomainAdministratorCredential = $Credential;
            DependsOn = '[xWindowsFeature]ADDomainServices';
        }

        foreach ($feature in @(
                'DHCP',
                'RSAT-DHCP'
            )) {
            xWindowsFeature $feature.Replace('-','') {
                Ensure = 'Present';
                Name = $feature;
                IncludeAllSubFeature = $true;
                DependsOn = '[xADDomain]ADDomain_corp_contoso_com';
            }
        }
        

        xDhcpServerAuthorization 'DHCP_Authorization' {
            Ensure = 'Present';
            DependsOn = '[xWindowsFeature]DHCP';
        }
        
        xDhcpServerScope 'DhcpScope_10_0_0_0' {
            Name = 'Corpnet';
            IPStartRange = '10.0.0.100';
            IPEndRange = '10.0.0.200';
            SubnetMask = '255.255.255.0';
            LeaseDuration = '00:08:00';
            State = 'Active';
            AddressFamily = 'IPv4';
            DependsOn = '[xWindowsFeature]DHCP';
        }

        xDhcpServerOption 'DhcpScope_10_0_0_0_Option' {
            ScopeID = '10.0.0.0';
            DnsDomain = 'corp.contoso.com';
            DnsServerIPAddress = '10.0.0.1';
            Router = '10.0.0.2';
            AddressFamily = 'IPv4';
            DependsOn = '[xDhcpServerScope]DhcpScope_10_0_0_0';
        }

        xDnsServerPrimaryZone 'DNS_Zone_0_0_10_InAddr_Arpa' {
            Name = '0.0.10.in-addr.arpa';
            ZoneFile = '0.0.10.in-addr.arpa.dns'
            DependsOn = '[xADDomain]ADDomain_corp_contoso_com';
        }
        
        xADUser 'ADUser_User1' { 
            DomainName = $node.DomainName;
            DomainAdministratorCredential = $domainCredential;
            UserName = 'User1';
            Password = $Credential;
            Ensure = 'Present';
            DependsOn = '[xADDomain]ADDomain_corp_contoso_com';
        }
    } #end nodes DC
}

#Clear-LabModuleCache -Verbose
#Remove-LabConfiguration -ConfigurationData $ConfigData
#remove-lab
#Install-module xPSDesiredStateConfiguration
#Install-module xComputerManagement, xNetworking, xActiveDirectory,xDHCPServer, xDnsServer

# Use the Data.psd1 in the same folder as this script
$ConfigData = "$(Split-Path $MyInvocation.MyCommand.Path)\data.psd1"
# Create a new credential that we'll pass to BasicServerClient (Required when creating the domain & joining the domain) and to Start-LabConfiguration
$AdministratorCredential = [pscredential]::new('Administrator', ('Password1' | ConvertTo-SecureString -AsPlainText -Force))

# Generate the .MOF files that will be injected into our VMs and used to set them up
Write-Host 'Generating MOFs' -ForegroundColor Green
BasicServerClient -ConfigurationData $ConfigData -OutputPath 'C:\Lability\Configurations' -Credential $AdministratorCredential -Verbose

# Verify lab configuration & see what parts of it already exist (if any)
Write-Host 'Verifying lab configuration' -ForegroundColor Green
Test-LabConfiguration -ConfigurationData $ConfigData -Verbose



# Create the lab from our config
Write-Host 'Creating lab' -ForegroundColor Green
Start-LabConfiguration -ConfigurationData $ConfigData -Verbose -IgnorePendingReboot -Credential $AdministratorCredential

# And once it's created, start the lab environment
Write-Host 'Starting lab!' -ForegroundColor Green
Start-Lab -ConfigurationData $ConfigData -Verbose
#>

<#
gcm -mod lability
stop-lab -ConfigurationData $ConfigData
Test-LabVM -ConfigurationData $ConfigData
#>
