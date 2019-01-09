function function1
{
    [cmdletbinding()]
    PARAM()
    BEGIN{write-verbose "function1 - BEGIN BLOCK"}
    PROCESS{
        1..10 | %{
            Write-Verbose "function1 - Value= $($_)"
            Write-Output $_
        }
    }
    END{write-verbose "function1 - END BLOCK"}
}

function function2
{
    [cmdletbinding()]
    PARAM(
    [parameter(ValueFromPipeline=$true)]
        $text
    )
    BEGIN{
        write-verbose "function2 - BEGIN BLOCK"
    }
    PROCESS{
        write-verbose "function2 - Value= $text"
        Write-Output "Received = $text"
    }
    END{
        write-verbose "function2 - END BLOCK"
    }
}


function1 -Verbose|function2 -Verbose