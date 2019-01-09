

<#
# Video
https://www.youtube.com/watch?v=16CYGTKH73U
# Article
https://kevinmarquette.github.io/2017-05-12-Powershell-Plaster-adventures-in/#second-deploy

#>

Install-Module Plaster


# Retrieve Template (aka Manifest)
Get-PlasterTemplate


# Creating Manifest
$Props = @{
    Path            = ".\LazyWinAdmin\PlasterManifest.xml"
    Title           = "LazyWinAdmin"
    TemplateName    = 'LazyWinAdminTemplate'
    TemplateVersion = '0.0.1'
    Author          = 'Francois-Xavier Cat'
}
# create folder
New-Item -Path $Props.path -ItemType Directory
# Create template/manifest
New-PlasterManifest @Props