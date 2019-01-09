$sb={
function Get-Something
{
    [CmdletBinding()]
    PARAM($a,$b)

   get-Process svchost -comp localhost| Select name
}
}
$Cmds=$sb.Ast.FindAll({
    [System.Management.Automation.Language.Ast]$ast = $args[0]
    $ast -is [System.Management.Automation.Language.CommandAst]
  }, $true)
  
foreach ($Binding in $cmds)
{
  Write-Verbose "Bind Command"
  $parameters=[System.Management.Automation.Language.StaticParameterBinder]::BindCommand($Binding)
  Write-Verbose $binding
  $parameters.BoundParameters.keys|% {
    $n=$_
    $v=$Parameters.BoundParameters[$n].ConstantValue                                    
    "$($Binding.CommandElements[0].value) -$n $v"
  }
}

# get-Process -Name svchost
# Select -Property name
