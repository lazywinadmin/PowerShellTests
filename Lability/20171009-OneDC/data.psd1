# Data.psd1

@{
    AllNodes = @(
        # All nodes
        @{
            NodeName                  = '*'
            DomainName                = 'Lab.local'

            # Networking
            Lability_SwitchName       = 'Private'
            DefaultGateway            = '10.0.0.254'
            AddressFamily             = 'IPv4'
            DnsServerAddress          = '10.0.0.1'
            DnsConnectionSuffix       = 'Lab.local'

            # DSC related
            PSDscAllowPlainTextPassword = $true
            PSDscAllowDomainUser      = $true            # Removes 'It is not recommended to use domain credential for node X' messages

        }

        # DC01
        @{
            # Basic details
            NodeName                  = 'DC01'
            Role                      = 'DC'
            Lability_Media            = '2016_x64_Standard_EN_Eval'
            # Networking
            IPAddress                 = '10.0.0.1/24'
            DnsServerAddress          = '127.0.0.1'
            # Lability extras
            Lability_CustomBootstrap  = @'

'@
        }
    )

    NonNodeData = @{
        OrganisationName = 'Lab'

        Lability = @{
            # Prefix all of our VMs with 'LAB-' in Hyper-V
            EnvironmentPrefix         = ''

            Network = @(
                @{
                    Name              = 'External_Network'
                    Type              = 'External'
                    NetadapterName    = 'Ethernet'
                    AllowManagementOS = $true
                }
            )

            DSCResource = @(
                @{ Name = 'xComputerManagement'; MinimumVersion = '1.3.0.0'; Provider = 'PSGallery' }
                @{ Name = 'xNetworking'; MinimumVersion = '2.7.0.0' }
                @{ Name = 'xActiveDirectory'; MinimumVersion = '2.9.0.0' }
                @{ Name = 'xDnsServer'; MinimumVersion = '1.5.0.0' }
                @{ Name = 'xDhcpServer'; MinimumVersion = '1.3.0.0' }
            )

            Media = @()
        }
    }
}