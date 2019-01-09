# Import PowerShellForGithub module
Install-Module -Name PowerShellForGitHub -Scope CurrentUser -verb -Force
Remove-module powershellforgithub
Import-Module -Name powershellforgithub # ..\PowerShellForGitHub\PowerShellForGitHub.psd1 -verb 
# Create new Github Token https://github.com/settings/tokens/new
# Set random username, password is your github key
$key = '<Your Key>'
$cred = Get-Credential -UserName $null
Set-GitHubAuthentication -Credential $cred

# List command
Get-Command -module PowerShellForGithub *issue*

# Retrieve issues
Get-GitHubIssue -Uri 'https://github.com/lazywinadmin/lazywinadmin.github.io'
Get-GitHubIssue -Uri 'https://github.com/lazywinadmin/lazywinadmin.github.io' -Label 'blog comments'

# Create an issue
$NewIssue = New-GitHubIssue -OwnerName lazywinadmin -RepositoryName lazywinadmin.github.io -Title PowerShellTest6 -Body test -Label 'blog comments','bug'
Get-GitHubLabel -OwnerName lazywinadmin -RepositoryName lazywinadmin.github.io

# Add a commnet
#New-GitHubComment -OwnerName lazywinadmin -RepositoryName lazywinadmin.github.io -Issue $NewIssue.number -Body '<p><a href="http://www.petri.co.il/protect-windows-ad-obects-accidental-deletion-recovery.htm" rel="nofollow noopener" title="http://www.petri.co.il/protect-windows-ad-obects-accidental-deletion-recovery.htm">http://www.petri.co.il/prot...</a></p>'
#New-GitHubComment -OwnerName lazywinadmin -RepositoryName lazywinadmin.github.io -Issue $NewIssue.number -Body '<p>ADAudit Plus is a valuable security tool that will help you be compliant with all the IT regulatory acts. With this tool, you can monitor user activity such as logon, file access, etc. A configurable alert system warns you of potential threats.<br><br><a href="http://www.manageengine.com/products/active-directory-audit/" rel="nofollow noopener" title="http://www.manageengine.com/products/active-directory-audit/">http://www.manageengine.com...</a></p>'

# Close issue
Update-GitHubIssue -OwnerName lazywinadmin -RepositoryName lazywinadmin.github.io -State closed -Issue $NewIssue.number





