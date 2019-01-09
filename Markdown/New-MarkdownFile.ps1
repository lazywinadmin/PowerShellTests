function New-MarkdownFile
{
<#
.SYNOPSIS
	Function to create a new Markdown file
	
#>
	[CmdletBinding()]
	PARAM (
		[System.String]$Path,
		[System.String]$Title,
		[System.String]$FileName,
		[datetime]$Date,
		[System.String]$Permalink,
		[System.String]$Content,
		[String]$Excerpt,
		[String]$Tags
	)
	
	
	# Example of Permalink
	#/:year/:month/Some-FakePostTitle-here-20161121.html
	
	$FileName = "$('{0:yyyy-MM-dd-}' -f $date)$FileName.md"
	
	
	if (($Tags -split ',').count -gt 1)
	{
		$Tags = ($Tags -split ',').trim() | sort-object | ForEach-Object{ "`r`n- $_" }
	}
	
	$FileContent =@"
---
title: $Title
excerpt: $Excerpt
permalink: $Permalink
tags: $Tags
---
$Content
"@
	
	#New-Item -ItemType File -Path $Path -Name $FileName
	#$FileContent |Out-File (Join-Path -Path $Path -ChildPath $FileName) -Encoding utf8
	
	$Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding($False)
	[System.IO.File]::WriteAllLines($(Join-Path -Path (Resolve-Path $Path).path -ChildPath $FileName), $FileContent, $Utf8NoBomEncoding)
	
}