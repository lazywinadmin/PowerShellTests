$out=gc .\dnscmd.txt
foreach ($line in $out)
{
    $line=$line -split '\s'

    $hash=@{
        ComputerName = $line[0]
        TTL = $line[-3]
        Type = $line[-2]
        IPAddress = $line[-1]
        Aging = ''
    }

    if($line[1] -match '^\['){
        $hash.Aging = $line[3] -replace '\]'
    }

    [pscustomobject]$hash
}