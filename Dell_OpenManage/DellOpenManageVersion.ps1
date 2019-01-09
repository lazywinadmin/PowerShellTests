################################################################
#Author: Francois-Xavier Cat
#Date: 2010/01/07
#Description: Get the OpenManage Version
# DellOpenManageVersion.ps1 -ComputerName (Get-Content Computerlist.txt)
################################################################
PARAM([String[]]$ComputerName)
foreach ($Computer in $ComputerName)
{
	$Out = "" | Select ComputerName,Version
	$out.ComputerName = $Computer
	$Query = Get-WmiObject -namespace "Root\CIMV2\Dell" -ComputerName $Computer -class Dell_SoftwareFeature -erroraction continue
	
	if($Query.Version)
	{
		$Out.Version = $query.version
	}
	else{
		$Out.Version = ''
	}
	
	Write-Output $out
}
