# MODULE
@"
function Get-Process {
    "Module"
}

Export-ModuleMember -Function Get-Process
"@ | Out-File mymodule.psm1

Import-Module .\mymodule.psm1


# FUNCTION

function Get-Process {
    "Function"
}



# Which one will be called when I call Get-Process ?
Get-Process


&(Get-Process)



Import-Module .\mymodule.psm1 -Prefix FX

Get-FXProcess


#cleanup
Remove-Item .\mymodule.psm1 -Force

# Alias
New-Alias -name Get-Process -value Get-Process