
<#PSScriptInfo

.VERSION 1.0

.GUID c1dcb1b8-34ca-4bb0-a085-bd1631e1556d

.AUTHOR Francois-Xavier Cat

.COMPANYNAME LazyWinAdmin.com

.COPYRIGHT 

.TAGS disqus,github,

.LICENSEURI 

.PROJECTURI 

.ICONURI 

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES

#>

<# 

.DESCRIPTION 
 Import Disqus Comments to Github Issues 

#>
[CmdletBinding()]
Param($Path)

# Import module
Import-module -Name PowerShellForGitHub

# Retrieve comments
$Comments = ..\PSDisqusImport\PSDisqusImport.ps1 -Path ..\PSDisqusImport\lazywinadmin-2018-10-03T01_14_58.548194-all.xml

# Group per blog post
$Comments | Group-Object -property ThreadPostTitle|Select-Object -expand group | Where-Object { $_.isspam -match 'false' }| Out-GridView
$Comments | Group-Object -property ThreadPostLink|Select-Object -expand group | Where-Object { $_.isspam -match 'false' }| ForEach-Object{
    # Multi Thread ?
    #$_.DsqID
    #$_.createdAt
    #$IssueTitle = 

    # Each blogpost have its own issue
    $BlogPath = ([uri]$($_.ThreadPostLink)).AbsolutePath -replace '^\/' -replace '\.html$'
}




