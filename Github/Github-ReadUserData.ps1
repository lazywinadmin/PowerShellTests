#https://github.com/pcgeek86/PSGitHub
Install-module -name psgithub -scope CurrentUser -Verbose
Import-Module -Name PSGIthub

# Read User
$PSDefaultParameterValues['*GitHub*:Token'] = '<KEY HERE>' | ConvertTo-SecureString -AsPlainText -force

gcm -mod psgithub
Get-githubauthenticateduser

Get-GithubIssue