<#
.Notes
	Credits to
#>
param( [string] $auditlist)

Function Get-CustomHTML ($Header){
$Report = @"
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Frameset//EN" "http://www.w3.org/TR/html4/frameset.dtd">
<html><head><title>$($Header)</title>
<META http-equiv=Content-Type content='text/html; charset=windows-1252'>

<meta name="save" content="history">

<style type="text/css">
DIV .expando {DISPLAY: block; FONT-WEIGHT: normal; FONT-SIZE: 8pt; RIGHT: 8px; COLOR: #ffffff; FONT-FAMILY: Arial; POSITION: absolute; TEXT-DECORATION: underline}
TABLE {TABLE-LAYOUT: fixed; FONT-SIZE: 100%; WIDTH: 100%}
*{margin:0}
.dspcont { display:none; BORDER-RIGHT: #B1BABF 1px solid; BORDER-TOP: #B1BABF 1px solid; PADDING-LEFT: 16px; FONT-SIZE: 8pt;MARGIN-BOTTOM: -1px; PADDING-BOTTOM: 5px; MARGIN-LEFT: 0px; BORDER-LEFT: #B1BABF 1px solid; WIDTH: 95%; COLOR: #000000; MARGIN-RIGHT: 0px; PADDING-TOP: 4px; BORDER-BOTTOM: #B1BABF 1px solid; FONT-FAMILY: Tahoma; POSITION: relative; BACKGROUND-COLOR: #f9f9f9}
.filler {BORDER-RIGHT: medium none; BORDER-TOP: medium none; DISPLAY: block; BACKGROUND: none transparent scroll repeat 0% 0%; MARGIN-BOTTOM: -1px; FONT: 100%/8px Tahoma; MARGIN-LEFT: 43px; BORDER-LEFT: medium none; COLOR: #ffffff; MARGIN-RIGHT: 0px; PADDING-TOP: 4px; BORDER-BOTTOM: medium none; POSITION: relative}
.save{behavior:url(#default#savehistory);}
.dspcont1{ display:none}
a.dsphead0 {BORDER-RIGHT: #B1BABF 1px solid; PADDING-RIGHT: 5em; BORDER-TOP: #B1BABF 1px solid; DISPLAY: block; PADDING-LEFT: 5px; FONT-WEIGHT: bold; FONT-SIZE: 8pt; MARGIN-BOTTOM: -1px; MARGIN-LEFT: 0px; BORDER-LEFT: #B1BABF 1px solid; CURSOR: hand; COLOR: #FFFFFF; MARGIN-RIGHT: 0px; PADDING-TOP: 4px; BORDER-BOTTOM: #B1BABF 1px solid; FONT-FAMILY: Tahoma; POSITION: relative; HEIGHT: 2.25em; WIDTH: 95%; BACKGROUND-COLOR: #CC0000}
a.dsphead1 {BORDER-RIGHT: #B1BABF 1px solid; PADDING-RIGHT: 5em; BORDER-TOP: #B1BABF 1px solid; DISPLAY: block; PADDING-LEFT: 5px; FONT-WEIGHT: bold; FONT-SIZE: 8pt; MARGIN-BOTTOM: -1px; MARGIN-LEFT: 0px; BORDER-LEFT: #B1BABF 1px solid; CURSOR: hand; COLOR: #ffffff; MARGIN-RIGHT: 0px; PADDING-TOP: 4px; BORDER-BOTTOM: #B1BABF 1px solid; FONT-FAMILY: Tahoma; POSITION: relative; HEIGHT: 2.25em; WIDTH: 95%; BACKGROUND-COLOR: #7BA7C7}
a.dsphead2 {BORDER-RIGHT: #B1BABF 1px solid; PADDING-RIGHT: 5em; BORDER-TOP: #B1BABF 1px solid; DISPLAY: block; PADDING-LEFT: 5px; FONT-WEIGHT: bold; FONT-SIZE: 8pt; MARGIN-BOTTOM: -1px; MARGIN-LEFT: 0px; BORDER-LEFT: #B1BABF 1px solid; CURSOR: hand; COLOR: #ffffff; MARGIN-RIGHT: 0px; PADDING-TOP: 4px; BORDER-BOTTOM: #B1BABF 1px solid; FONT-FAMILY: Tahoma; POSITION: relative; HEIGHT: 2.25em; WIDTH: 95%; BACKGROUND-COLOR: #7BA7C7}
a.dsphead1 span.dspchar{font-family:monospace;font-weight:normal;}
td {VERTICAL-ALIGN: TOP; FONT-FAMILY: Tahoma}
th {VERTICAL-ALIGN: TOP; COLOR: #CC0000; TEXT-ALIGN: left}
BODY {margin-left: 4pt} 
BODY {margin-right: 4pt} 
BODY {margin-top: 6pt} 
</style>


<script type="text/javascript">
function dsp(loc){
   if(document.getElementById){
      var foc=loc.firstChild;
      foc=loc.firstChild.innerHTML?
         loc.firstChild:
         loc.firstChild.nextSibling;
      foc.innerHTML=foc.innerHTML=='hide'?'show':'hide';
      foc=loc.parentNode.nextSibling.style?
         loc.parentNode.nextSibling:
         loc.parentNode.nextSibling.nextSibling;
      foc.style.display=foc.style.display=='block'?'none':'block';}}  

if(!document.getElementById)
   document.write('<style type="text/css">\n'+'.dspcont{display:block;}\n'+ '</style>');
</script>

</head>
<body>
<b><font face="Arial" size="5">$($Header)</font></b><hr size="8" color="#CC0000">
<font face="Arial" size="1"><b>Version 3  | Jean Louw | <A HREF='http://powershellneedfulthings.blogspot.com'>powershellneedfulthings.blogspot.com</A></b></font><br>
<font face="Arial" size="1">Report created on $(Get-Date)</font>
<div class="filler"></div>
<div class="filler"></div>
<div class="filler"></div>
<div class="save">
"@
Return $Report
}

Function Get-CustomHeader0 ($Title){
$Report = @"
		<h1><a class="dsphead0">$($Title)</a></h1>
	<div class="filler"></div>
"@
Return $Report
}

Function Get-CustomHeader ($Num, $Title){
$Report = @"
	<h2><a href="javascript:void(0)" class="dsphead$($Num)" onclick="dsp(this)">
	<span class="expando">show</span>$($Title)</a></h2>
	<div class="dspcont">
"@
Return $Report
}

Function Get-CustomHeaderClose{

	$Report = @"
		</DIV>
		<div class="filler"></div>
"@
Return $Report
}

Function Get-CustomHeader0Close{

	$Report = @"
</DIV>
"@
Return $Report
}

Function Get-CustomHTMLClose{

	$Report = @"
</div>

</body>
</html>
"@
Return $Report
}

Function Get-HTMLTable{
	param([array]$Content)
	$HTMLTable = $Content | ConvertTo-Html
	$HTMLTable = $HTMLTable -replace '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">', ""
	$HTMLTable = $HTMLTable -replace '<html xmlns="http://www.w3.org/1999/xhtml">', ""
	$HTMLTable = $HTMLTable -replace '<head>', ""
	$HTMLTable = $HTMLTable -replace '<title>HTML TABLE</title>', ""
	$HTMLTable = $HTMLTable -replace '&lt;', "<"
	$HTMLTable = $HTMLTable -replace '&gt;', ">"
	$HTMLTable = $HTMLTable -replace '</head><body>', ""
	$HTMLTable = $HTMLTable -replace '</body></html>', ""
	Return $HTMLTable
}

Function Get-HTMLLink ($activeURL){
$Report = @"
<a href=$activeURL>$activeURL</a>
"@
Return $Report 
}

Function Get-Ink ([String]$inData){
[String]$inclPercentage = @(35..100)
$positive = ($inclPercentage, 'Success', 'Ready', 'Running', 'OK', 'True', 'Information')
If ($positive -match $inData)
{
$Report = @"
<font color='#009900'>$inData</font>
"@
}
Else
{
$Report = @"
<font color='#FF0000'>$inData</font>
"@
}
Return $Report
}

Function Get-HTMLBasic ($Detail){
$Report = @"
<TABLE>
	<tr>
		<td width='75%'>$($Detail)</td>
	</tr>
</TABLE>
"@
Return $Report
}

Function Get-HTMLDetail ($Heading, $Detail){
$Report = @"
<TABLE>
	<tr>
	<th width='25%'><b>$Heading</b></font></th>
	<td width='75%'>$($Detail)</td>
	</tr>
</TABLE>
"@
Return $Report
}

$input | foreach {$targets += @($_)}
If ((Test-Path variable:\targets) -eq $True){
			Write-Host "Server list input detected on pipeline" -ForegroundColor Yellow
			}
Else{
	if ($auditlist -eq ""){
			Write-Host "No server list specified, getting all Exchange 2007 servers" -ForegroundColor Yellow
			$targets = Get-ExchangeServer | Where-Object {$_.IsExchange2007OrLater -eq $True}
		}
		else
		{
			if ((Test-Path $auditlist) -eq $false)
			{
				Write-Host "Invalid server list specified: $auditlist" -ForegroundColor DarkRed
				exit
			}
			else
			{
				Write-Host "Using Audit list: $auditlist" -ForegroundColor Cyan
				$Targets = Get-Content $auditlist
			}
			}
}

$now = Get-Date
#Custom Expressions
$latencyMS = @{Name="Latency(MS)";expression={[Math]::Round(([TimeSpan] $_.Latency).TotalMilliSeconds)}}
$hotLink = @{Name="URL";expression={Get-HTMLLink ($_.URL)}}
$colourResult = @{Name="Result";expression={Get-Ink ($_.Result)}}
$colourStatus = @{Name="Status";expression={Get-Ink ($_.Status)}}
$colourType = @{Name="Status";expression={Get-Ink ($_.Type)}}
$newResult = @{Name="Result";expression={If ($_.Result.ToString() -ne 'Success'){Get-Ink ('Failure')} Else {Get-Ink ('Success') }}}

Foreach ($Target in $Targets){

Write-Host "Collating Detail for $Target" -ForegroundColor Yellow
	Write-Host "..getting basic computer configuration"
	$ComputerSystem = Get-WmiObject -computername $Target Win32_ComputerSystem
	switch ($ComputerSystem.DomainRole){
		0 { $ComputerRole = "Standalone Workstation" }
		1 { $ComputerRole = "Member Workstation" }
		2 { $ComputerRole = "Standalone Server" }
		3 { $ComputerRole = "Member Server" }
		4 { $ComputerRole = "Domain Controller" }
		5 { $ComputerRole = "Domain Controller" }
		default { $ComputerRole = "Information not available" }
	}
	
	$OperatingSystems = Get-WmiObject -computername $Target Win32_OperatingSystem
	$TimeZone = Get-WmiObject -computername $Target Win32_Timezone
	$Keyboards = Get-WmiObject -computername $Target Win32_Keyboard
	$SchedTasks = Get-WmiObject -computername $Target Win32_ScheduledJob
	$BootINI = $OperatingSystems.SystemDrive + "boot.ini"
	$RecoveryOptions = Get-WmiObject -computername $Target Win32_OSRecoveryConfiguration
	$exServer = Get-ExchangeServer | where {$_.Name -eq "$Target"}
	$exVersion = "Version " + $exServer.AdminDisplayVersion.Major + "." + $exServer.AdminDisplayVersion.Minor + " (Build " + $exServer.AdminDisplayVersion.Build + "." + $exServer.AdminDisplayVersion.Revision + ")"

	switch ($ComputerRole){
		"Member Workstation" { $CompType = "Computer Domain"; break }
		"Domain Controller" { $CompType = "Computer Domain"; break }
		"Member Server" { $CompType = "Computer Domain"; break }
		default { $CompType = "Computer Workgroup"; break }
	}

	$LBTime=$OperatingSystems.ConvertToDateTime($OperatingSystems.Lastbootuptime)
	$MyReport = Get-CustomHTML "$Target Exchange Audit"
	$MyReport += Get-CustomHeader0  "$Target - Role(s): $($exServer.ServerRole)"
	$MyReport += Get-CustomHeader "2" "Basic Server Information"
		$MyReport += Get-HTMLDetail "Computer Name" ($ComputerSystem.Name)
		$MyReport += Get-HTMLDetail "Computer Role" ($ComputerRole)
		$MyReport += Get-HTMLDetail $CompType ($ComputerSystem.Domain)
		$MyReport += Get-HTMLDetail "Operating System" ($OperatingSystems.Caption)
		$MyReport += Get-HTMLDetail "Service Pack" ($OperatingSystems.CSDVersion)
		$MyReport += Get-HTMLDetail "Exchange Version" ($exVersion)
		$MyReport += Get-HTMLDetail "Exchange Edition" ($exServer.Edition)
		$MyReport += Get-HTMLDetail "Exchange Role(s)" ($exServer.ServerRole)
		$MyReport += Get-HTMLDetail "System Root" ($OperatingSystems.SystemDrive)
		$MyReport += Get-HTMLDetail "Manufacturer" ($ComputerSystem.Manufacturer)
		$MyReport += Get-HTMLDetail "Model" ($ComputerSystem.Model)
		$MyReport += Get-HTMLDetail "Number of Processors" ($ComputerSystem.NumberOfProcessors)
		$MyReport += Get-HTMLDetail "Memory (GB)" ([math]::round(($ComputerSystem.TotalPhysicalMemory / 1GB)))
		$MyReport += Get-HTMLDetail "Registered User" ($ComputerSystem.PrimaryOwnerName)
		$MyReport += Get-HTMLDetail "Registered Organisation" ($OperatingSystems.Organization)
		$MyReport += Get-HTMLDetail "Last System Boot" ($LBTime)
		$MyReport += Get-CustomHeaderClose
		
		Write-Host "..getting Exchange rollup information"
		$colInstalledRollups = @()
		$baseKey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $Target)
		$subKey = "SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Products\461C2B4266EDEF444B864AD6D9E5B613\Patches\"
    	$baseKey = $baseKey.OpenSubKey($subKey)
		$rollUps = $baseKey.GetSubKeyNames()

    	ForEach($rollUp in $rollUps)
		{
        	$fullPath= $subKey + $rollUp
       	 	$childKey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $Target)
        	$childKey = $childKey.OpenSubKey($fullPath)
			$values = $childKey.GetValueNames()
		
        ForEach($value in $values)
		{
		    if ($value -eq "DisplayName") 
			{	
				$colInstalledRollups += $childKey.GetValue($value)
			}
        }
    	}
		$MyReport += Get-CustomHeader "2" "Installed Exchange Rollups"
		$objInstalledRollupNumber = 1
		ForEach ($objInstalledRollup in $colInstalledRollups)
		{
			$MyReport += Get-HTMLBasic ($objInstalledRollup)
			$objInstalledRollupNumber ++
		}
		$MyReport += Get-CustomHeaderClose
		Write-Host "..getting logical disk configuration"
		$Disks = Get-WmiObject -ComputerName $Target Win32_LogicalDisk
		$MyReport += Get-CustomHeader "2" "Logical Disk Configuration"
			$LogicalDrives = @()
			Foreach ($LDrive in ($Disks | Where {$_.DriveType -eq 3})){
				$Details = "" | Select "Drive Letter", Label, "File System", "Disk Size (GB)", "Disk Free Space", "% Free Space"
				$Details."Drive Letter" = $LDrive.DeviceID
				$Details.Label = $LDrive.VolumeName
				$Details."File System" = $LDrive.FileSystem
				$Details."Disk Size (GB)" = [math]::round(($LDrive.size / 1GB))
				$Details."Disk Free Space" = [math]::round(($LDrive.FreeSpace / 1GB))
				$Details."% Free Space" = Get-Ink ([Math]::Round(($LDrive.FreeSpace /1GB) / ($LDrive.Size / 1GB) * 100))
				$LogicalDrives += $Details
			}
			$MyReport += Get-HTMLTable ($LogicalDrives)
		$MyReport += Get-CustomHeaderClose
		
		if ($exServer.ServerRole -like "*ClientAccess*")
		{
			$MyReport += Get-CustomHeader "2" "OWA Connectivity"
			Write-Host "..performing OWA connectivity test"
			$colOWAResults = Test-OwaConnectivity -ClientAccessServer $Target
			$MyReport += Get-HTMLTable ($colOWAResults | select MailboxServer, $hotLink, Scenario, $colourResult, $latencyMS, Error)
			$MyReport += Get-CustomHeaderClose
			$MyReport += Get-CustomHeader "2" "ActiveSync Connectivity"
			Write-Host "..performing ActiveSync connectivity test"
			$colActiveSyncResults = Test-ActiveSyncConnectivity -ClientAccessServer $Target.ToString()
			$MyReport += Get-HTMLTable ($colActiveSyncResults | select MailboxServer, Scenario, $colourResult, $latencyMS, Error)
			$MyReport += Get-CustomHeaderClose
			$MyReport += Get-CustomHeader "2" "Outlook Web Services"
			Write-Host "..performing Outlook Web Services test"
			$colOWSResults = Test-OutlookWebServices -ClientAccessServer $ComputerSystem.Name
			$MyReport += Get-HTMLTable ($colOWSResults | select $colourType, Message)
			$MyReport += Get-CustomHeaderClose
		}
		
		Write-Host "..getting queue details"
		if ($exServer.ServerRole -like "*HubTransport*")
		{
		$MyReport += Get-CustomHeader "2" "Queue Information"
		$colQs = Get-Queue -server $Target 
		$MyReport += Get-HTMLTable ($colQs | Select-Object NextHopDomain, $colourStatus, MessageCount, NextRetryTime)
		$MyReport += Get-CustomHeaderClose
		}
		
		$spaceLog=[System.Diagnostics.EventLog]::GetEventLogs($target) | where {($_.LogDisplayName -eq "Application")}
		$db = @{Name="database";Expression={$_.ReplacementStrings[1]}}
		$freeMB = @{Name="MB";Expression={[int]$_.ReplacementStrings[0]}}
		$whiteSpace = $spaceLog.entries | where {($_.TimeWritten -ge $now.AddDays(-1))} | where {($_.EventID -eq "1221")} | select $db,$freeMB
		$ws = @{Name="White Space";expression={}}
				
		if ($exServer.ServerRole -like "*Mailbox*")
		{
			Write-Host "..getting mailbox database information"
			$MyReport += Get-CustomHeader "2" "Mailbox Stores"
			$colMailboxStores = Get-MailboxDatabase -Server $Target -Status | Sort-Object Name
			$storeTable = @()
			Foreach ($objMailboxStore in $colMailboxStores)
			{
				[string]$totalUsers = (get-mailbox -database $objMailboxStore).count
				[string]$empty = $totalUsers.Length -eq 0
		
				if ($empty -eq 'True')
				{
					[string]$totalUsers = "0"
				}
				$storeDetails = "" | Select Name, Mounted, "Total Users", "White Space", LastFullBackup
				$storeDetails.Name = $objMailboxStore.Name
				$storeDetails.Mounted = Get-Ink ($objMailboxStore.Mounted)
				$storeDetails."Total Users" = $totalUsers
				$storeDetails."White Space" = (($whitespace | where {$_.database -match $objMailboxStore.Name} | select -last 1).mb)
				$storeDetails.LastFullBackup = $objMailboxStore.LastFullBackup
				$storeTable += $storeDetails
			}
				$MyReport += Get-HTMLTable ($storeTable)
			$MyReport += Get-CustomHeaderClose
			
			$MyReport += Get-CustomHeader "2" "MAPI Connectivity"
			Write-Host "..performing MAPI connectivity test"
			$colMAPIResults = Test-MAPIConnectivity -Server $Target
				$MyReport += Get-HTMLTable ($colMAPIResults | select Database, $newResult, $latencyMS, Error)
			$MyReport += Get-CustomHeaderClose
		}
		
		Write-Host "..getting Exchange services"
		$ListOfServices = (gwmi -computer $Target -query "select * from win32_service where Name like 'MSExchange%' or Name like 'IIS%' or Name like 'SMTP%' or Name like 'POP%' or Name like 'W3SVC%'")
		$MyReport += Get-CustomHeader "2" "Exchange Services"
			$Services = @()
			Foreach ($Service in $ListOfServices){
				$Details = "" | Select Name,Account,"Start Mode",State,"Expected State"
				$Details.Name = $Service.Caption
				$Details.Account = $Service.Startname
				$Details."Start Mode" = $Service.StartMode
				If ($Service.StartMode -eq "Auto")
					{
						if ($Service.State -eq "Stopped")
						{
							$Details.State = $Service.State
							$Details."Expected State" = Get-Ink ("Unexpected")
						}
					}
					If ($Service.StartMode -eq "Auto")
					{
						if ($Service.State -eq "Running")
						{
							$Details.State = $Service.State
							$Details."Expected State" = Get-Ink ("OK")
						}
					}
					If ($Service.StartMode -eq "Disabled")
					{
						If ($Service.State -eq "Running")
						{
							$Details.State = $Service.State
							$Details."Expected State" = Get-Ink ("Unexpected")
						}
					}
					If ($Service.StartMode -eq "Disabled")
					{
						if ($Service.State -eq "Stopped")
						{
							$Details.State = $Service.State
							$Details."Expected State" = Get-Ink ("OK")
						}
					}
					If ($Service.StartMode -eq "Manual")
					{
						$Details.State = $Service.State
						$Details."Expected State" = Get-Ink ("OK")
					}
					If ($Service.State -eq "Paused")
					{
						$Details.State = $Service.State
						$Details."Expected State" = Get-Ink ("OK")
					}
				$Services += $Details
			}
				$MyReport += Get-HTMLTable ($Services)
			$MyReport += Get-CustomHeaderClose
		
				$eventLogs=[System.Diagnostics.EventLog]::GetEventLogs($Target) | where {($_.LogDisplayName -eq "Application") -OR ($_.LogDisplayName -eq "System")}
				$warningEvents = @()
				$errorEvents = @()
				$LogSettings = @()
			Write-Host "..getting event log settings"
			ForEach ($eventLog in $eventLogs)
			{
				$Details = "" | select "Log Name", "Overflow Action", "Maximum Kilobytes"
				$Details."Log Name" = $eventLog.LogDisplayName
				$MaximumKilobytes = ($eventLog.MaximumKilobytes)
				$Details."Maximum Kilobytes" = $MaximumKilobytes
				$Details."Overflow Action" = $eventLog.OverflowAction
				$LogSettings += $Details
				Write-Host "..getting event log warnings for" $eventLog.LogDisplayName "Log"
				$warningEvents += ($eventLog.entries) | ForEach-Object { Add-Member -inputobject $_ -Name LogName -MemberType NoteProperty -Value $eventLog.LogDisplayName -Force -PassThru} | where {($_.TimeWritten -ge $now.AddDays(-1))} | where {($_.EntryType -eq "Warning")} | where {($_.Source -like "*MSExchange*" -or $_.Source -like "*ESE*")}
				Write-Host "..getting event log errors for" $eventLog.LogDisplayName "Log"
				$errorEvents += ($eventLog.entries) | ForEach-Object { Add-Member -inputobject $_ -Name LogName -MemberType NoteProperty -Value $eventLog.LogDisplayName -Force -PassThru} | where {($_.TimeWritten -ge $now.AddDays(-1))} | where {($_.EntryType -eq "Error")} | where {($_.Source -like "*MSExchange*" -or $_.Source -like "*ESE*")}
			}
					$MyReport += Get-CustomHeader "2" "Event Logs"
				$MyReport += Get-CustomHeader "2" "Event Log Settings"
				$MyReport += Get-HTMLTable ($LogSettings)
			$MyReport += Get-CustomHeaderClose
			
					$MyReport += Get-CustomHeader "2" "Warning Events"
				$MyReport += Get-HTMLTable ($warningEvents | select EventID, Source, TimeWritten, LogName, Message)
			$MyReport += Get-CustomHeaderClose
					$MyReport += Get-CustomHeader "2" "Error Events"
				$MyReport += Get-HTMLTable ($errorEvents | select EventID, Source, TimeWritten, LogName, Message)
			$MyReport += Get-CustomHeaderClose
		$MyReport += Get-CustomHeaderClose
		$MyReport += Get-CustomHeaderClose
	$MyReport += Get-CustomHeader0Close
	$MyReport += Get-CustomHTMLClose
	$MyReport += Get-CustomHTMLClose
	$finaleReport += $MyReport

	$Date = Get-Date
	$Filename = ".\" + $Target + "_" + $date.Hour + $date.Minute + "_" + $Date.Day + "-" + $Date.Month + "-" + $Date.Year + ".htm"
	$MyReport | out-file -encoding ASCII -filepath $Filename
	Write "Audit saved as $Filename"
}