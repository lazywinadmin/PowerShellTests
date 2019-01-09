#Requires -version 3 
#Requires -modules posh-ssh
function get-HPSwitchConfig {
<#

.SYNOPSIS
Retrieve configuration from an HP Procurve Switch via SFTP, store, and timestamp it in a repository.

.NOTES
WARNING: Copying config via SFTP has been observed to interrupt the data forwarding on a 2810 switch for a few seconds. ONLY PERFORM OFF HOURS
This requires the POSH-SSH powershell module (https://github.com/darkoperator/Posh-SSH) 
You also need to enable SFTP on the switch via "ip ssh filetransfer" command before this will work.
Also it will not work if you already have 4 concurrent management sessions to your switch as it counts as a management session.
Make sure you don't have any SSH or SFTP sessions open to the switch you are about to pull from, some HP switches don't allow more than 1 SSH session from a host at a time.

.PARAMETER switchHost

DNS Name or IP address of the switch to connect to. If multiple strings are passed by pipeline, this will retrieve the config for each switch

.PARAMETER startupconfig

Retrieves the switch's startup config instead of the running config

.EXAMPLE 

Get-HPSwitchConfig -switchhost "switch1"

Retrieve running config from switch

.EXAMPLE 
"switch1","switch2","switch3","switch4" | get-hpswitchconfig -startupconfig
Gets the Startup config from 4 different switches
#>

param (
        [parameter(Mandatory=$true,ValuefromPipeline=$true)][string]$switchHost,
        [PSCredential]$switchCredential = (get-credential -message "Enter Procurve SSH Admin Credentials"),
        [Switch]$StartupConfig, #Gets running config by default
        [int]$timeout = 10,
        [String]$RepositoryPath = "$env:temp\SwitchConfigRepository" # Where to store configs
)

begin {
    $erroractionpreference = "stop"
    if (-Not (test-path $RepositoryPath)) {throw "Cannot find Output Path $RepositoryPath. Please ensure it exists."}
} #Begin
process { foreach ($switch in $switchHost) { #Unpack array if it is passed as single object

    $cfgFile="running-config"
    if ($startupconfig) {$cfgFile = "startup-config"}
    $cfgFileSourcePath="/cfg/$cfgfile"
    $cfgOutputPath = new-item -ItemType Directory -path "$RepositoryPath\$switchhost" -force


    #If an SFTP session already exists for this host, kill it
    if (get-sftpsession | where {$_.host -match $switch}) {$removedsession=remove-sftpsession (get-sftpsession | where {$_.host -match $switch})}

    #Try to get the config, capture any errors and skip if anything goes wrong. No result implies it worked.
    try {
        $sftpSession = new-sftpsession $switch -credential $switchcredential -connectiontimeout $timeout -operationtimeout $timeout 
        if (-Not $sftpsession.connected) {write-error "Could not connect to $switch. Please check connectivity and credentials.";return}

        get-sftpfile $sftpsession -RemoteFile $cfgFileSourcePath -LocalPath $cfgOutputPath -overwrite 
        if (-Not (test-path $cfgoutputpath\$cfgfile)) {throw "File not downloaded"}
    } #Try
    catch [Exception] {write-error "Error while downloading $switchHost configuration, please ensure you have enabled IP SSH Fileserver and do not have multiple sessions or current SSH/SFTP sessions from this host in other programs";return}
    
    #Close SFTP Session
    remove-sftpsession $sftpSession
    #Create a copy of the file with the timestamp date, removing colons from UTC sortable time as they aren't valid file characters
    $cfgfilepath = copy-item "$cfgOutputPath\$cfgfile" -destination ("$cfgOutputPath\$cfgfile-" + ((get-date -format s) -replace ':','') + ".hpconfig") -passthru

    #Create a status return object
    $objStatusProps = @{}
        $objStatusProps.Switch = $switch
        $objStatusProps.ConfigFilePath = $cfgfilepath.fullname
    $objStatus = new-object -TypeName PSObject -property $objStatusProps
    return $objStatus

}} #Foreach #Process




}#Function