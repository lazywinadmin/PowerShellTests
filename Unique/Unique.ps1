1,2,2,3,4,5,5,6,7,7 | Select-Object -Unique
# Get-Unique works only with sorted lists
1,2,2,3,4,5,5,6,7,7 | Sort-Object | Get-Unique 
# hashsets only store unique items
([System.Collections.Generic.HashSet[int]] $set = 1,2,2,3,4,5,5,6,7,7)
# Language Integrated Query
[Linq.Enumerable]::Distinct([int[]]@(1,2,2,3,4,5,5,6,7,7))

$ScriptBlock = {1,2,2,3,4,5,5,6,7,7 | Select-Object -Unique},
               {1,2,2,3,4,5,5,6,7,7 | Sort-Object |Get-Unique},
               {([System.Collections.Generic.HashSet[int]] $set = 1,2,2,3,4,5,5,6,7,7)},
               {[Linq.Enumerable]::Distinct([int[]]@(1,2,2,3,4,5,5,6,7,7))}

# measure execution times
ForEach($SB in $ScriptBlock){        

    $time = ForEach($n in 0..9999){
        (Measure-Command $SB).TotalMilliseconds
    }

    [pscustomobject]@{
        Expression=$SB
        TotalMilliSecs='{0:n5}' -f ($time|Measure-Object -Average).Average
    }

}