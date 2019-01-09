$Account = "*@*.onmicrosoft.com"
$Credential = Get-Credential -Credential $Account

# Retrieve events
$Uri = "https://outlook.office365.com/api/v1.0/users/$Account/calendarview?startDateTime=$(Get-Date)&endDateTime=$((Get-Date).AddDays(7))"
Invoke-RestMethod -Uri $uri -Credential $Credential |
foreach-object { $_.Value }

# Retrieve Organizers (property 'Organizer')
Invoke-RestMethod -Uri $uri -Credential $Credential |
foreach-object{ $_.Value } |
Select -ExpandProperty organizer


# Retrieve events
$Uri = "https://outlook.office365.com/api/v1.0/users/$Account/events?"
Invoke-RestMethod -Uri $uri -Credential $Credential |
    Select-Object -ExpandProperty Value|
    Select-Object -prop subject, @{L = 'Organizers'; E = {($_.organizer.emailaddress|
        select -ExpandProperty name -Unique)}}

Invoke-RestMethod -Uri $uri -Credential $Credential |
    Select-Object -ExpandProperty Value -OutVariable f
$f.organizer.emailaddress| select name -Unique

# Retrieve events id
$Uri = "https://outlook.office365.com/api/v1.0/users/$Account/events?"
(Invoke-RestMethod -Uri $uri -Credential $Credential).value.id
