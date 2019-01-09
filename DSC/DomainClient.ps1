$Config = @{
    AllNodes = @(
        @{
            NodeName                    = "APP01"
            PSDscAllowPlainTextPassword = $true
            PSDscAllowDomainUser        = $true
            IPAddress                   = '10.0.0.10/24'
            DnsServerAddress            = '10.0.0.1'
        }
    )
}


Configuration MyLocalConfig {
    PARAM($Credential)

    Write-Verbose 'Import DSC Resources - xComputerManagement'
    Import-DscResource -ModuleName xComputerManagement

    Write-Verbose 'Import DSC Resources - xNetworking'
    Import-DscResource -ModuleName xNetworking


    Node $AllNodes.Where( { $true }).NodeName {

        Write-Verbose "Processing:   $($node.NodeName)"

        # LCM settings
        LocalConfigurationManager {
            RebootNodeIfNeeded   = $true
            AllowModuleOverwrite = $true
            ConfigurationMode    = 'ApplyAndAutoCorrect'
            #CertificateID       = $node.Thumbprint
        }

        $domainCredential = New-Object System.Management.Automation.PSCredential("$($Credential.UserName)@fx.lab", $Credential.Password);

        xComputer 'Domain' {
            Name        = $node.NodeName;
            DomainName  = 'FX.lab';
            Credential  = $domainCredential #Domain credential
            Description = 'From DSC'
        }
        xIPAddress 'IP' {
            IPAddress      = $Node.IPAddress
            AddressFamily  = 'IPv4'
            InterfaceAlias = 'Ethernet'
        }
        xDNSServerAddress 'DNS' {
            Address        = $Node.DnsServerAddress
            InterfaceAlias = 'Ethernet'
            AddressFamily  = 'IPv4'
        }
    }
}
$Credential = [pscredential]::new('Administrator', ('Password1' | ConvertTo-SecureString -AsPlainText -Force))
MyLocalConfig -Credential $Credential -ConfigurationData $Config

Start-DscConfiguration .\MyLocalConfig -Verbose -Wait -Force

#Start-DscConfiguration -UseExisting -Wait -Verbose
#Get-DscConfigurationStatus -All
