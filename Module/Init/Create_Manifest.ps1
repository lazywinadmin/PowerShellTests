$ModuleName = "FXDemo"
$Author = "Francois-Xavier Cat"
$AuthorCompany = "Lazywinadmin.com"
$Tags = "demo"
$ModuleVersion = "1.0.0.0"
$PowerShellVersion = "3.0"
$Description = "Test module"
$CopyRight =  "(c) $(Get-date -f yyyy) Francois-Xavier Cat. All rights reserved. Licensed under The MIT License (MIT)"
$LicenseURI = "https://github.com/lazywinadmin/$ModuleName/blob/master/LICENSE.md"
$ProjectURI = "https://github.com/lazywinadmin/$ModuleName/"
$RequiredAssemblies = ''

# Create Folders Structure

# Create a Basic README.MD

# Set the License



New-ModuleManifest `
-RootModule "$ModuleName.psm1" `
-Path .\$ModuleName.psd1 `
-Guid ([guid]::NewGuid()) `
-RequiredAssemblies $RequiredAssemblies `
-Author $Author `
-CompanyName $AuthorCompany `
-ModuleVersion $ModuleVersion `
-Description $Description `
-Copyright $CopyRight `
-FunctionsToExport * `
-Tags $Tags `
-PowerShellVersion $PowerShellVersion `
-LicenseUri $LicenseURI `
-ProjectUri $ProjectURI


@'
  #Get public and private function definition files.
$Public = @(Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue)
$Private = @(Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue)

#Dot source the files
Foreach ($import in @($Public + $Private))
{
	TRY
	{
		. $import.fullname
	}
	CATCH
	{
		Write-Error -Message "Failed to import function $($import.fullname): $_"
	}
}

# Export all the functions
Export-ModuleMember -Function $Public.Basename -Alias *
  
'@|Out-File ".\$ModuleName.psm1"