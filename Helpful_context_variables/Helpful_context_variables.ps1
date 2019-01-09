# $MyInvocation, $PSCmdlet, $PSVersionTable and Environment Variables

# Show the current function name in your verbose message
$FunctionName= (Get-Variable -Name Myinvocation -Scope 0).MyCommand
# you can also use $MyInvocation.MyCommand

# Show the arguments used to invoke the function
Write-Verbose -Message "[$FunctionName] Argument '$($PsCmdlet.Myinvocation.Line)'" 

# Show the ParameterSetName used 
Write-Verbose -Message "[$FunctionName] ParametersetName '$($PsCmdlet.ParameterSetName)'"

# Show the version of Powershell and the bit process
Write-Verbose -Message "[$FunctionName] Powershell Version $($PSVersionTable.PSVersion.ToString()) in a $([intptr]::size * 8) bit process"
 
# Show the current Domain and User 
Write-Verbose -Message "[$FunctionName] User: '$([System.Environment]::UserDomainName)\$([System.Environment]::UserName)'"

function Get-Something
{
	[CmdletBinding()]
	PARAM (
		[Parameter(ParameterSetName = 'A')]
		$One,
		[Parameter(ParameterSetName = 'B')]
		$Two
	)
	
	
	# Show the current function name in your verbose message
	$FunctionName = ( Get-Variable -Name MyInvocation -Scope 0 -ValueOnly).Mycommand

	# you can also use $MyInvocation.MyCommand
	
	# Show the arguments used to invoke the function
	Write-Verbose -Message "[$FunctionName] Argument '$($PsCmdlet.Myinvocation.Line)'"
	
	# Show the ParameterSetName used 
	Write-Verbose -Message "[$FunctionName] ParametersetName '$($PsCmdlet.ParameterSetName)'"
	
	# Show the version of Powershell and the bit process
	Write-Verbose -Message "[$FunctionName] Powershell Version $($PSVersionTable.PSVersion.ToString()) in a $([intptr]::size * 8) bit process"
	
	# Show the current Domain and User 
	Write-Verbose -Message "[$FunctionName] User: '$([System.Environment]::UserDomainName)\$([System.Environment]::UserName)'"

}

Get-Something -One Bonjour -Verbose