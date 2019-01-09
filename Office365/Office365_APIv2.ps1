﻿$Account = "Youremail@lm.onmicrosoft.com"
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



Function Get-MVPOAuthAutorizationCode {
<#
.SYNOPSIS
    Get an Oauth 2.0 autorization code

.DESCRIPTION
    Use the authorization code grant flow described on https://msdn.microsoft.com/en-us/library/hh243647.aspx
    Pop-up a window that asks you to grant permissions to the mvpapi.portal.azure-api.net application and
    parse the returned url to catch the authorization code

.PARAMETER SubscriptionKey
    It's the primary key or secondary key you get in your profile on this page https://mvpapi.portal.azure-api.net/developer

.PARAMETER ClientID
    It's the clientID you see in the url of the MVPAuth application on your https://account.live.com/consent/Manage page

.EXAMPLE
    Set-MVPConfiguration -CliendID '0000000048193351' -SubscriptionKey $myKey 
#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory)]
    [String]$ClientID,

    [Parameter(Mandatory)]
    [string]$SubscriptionKey
)
Begin {
    $Scriptname = (Get-Variable -name MyInvocation -Scope 0 -ValueOnly).MyCommand

    Write-Verbose -Message "[$ScriptName] Set Variables"
    $scope = 'wl.emails%20wl.basic%20wl.offline_access%20wl.signin'
    $RedirectUri  = 'https://login.live.com/oauth20_desktop.srf'
    $AuthorizeUri = 'https://login.live.com/oauth20_authorize.srf'
    $u1 = '{0}?client_id={1}&redirect_uri={2}&response_type=code&scope={3}' -f $AuthorizeUri,$ClientID,$RedirectUri,$scope

    Write-Verbose -Message "[$ScriptName] Scope = '$scope'"
    Write-Verbose -Message "[$ScriptName] RedirectUri = '$RedirectUri'"
    Write-Verbose -Message "[$ScriptName] AuthorizeUri = '$AuthorizeUri'"
    Write-Verbose -Message "[$ScriptName] u1 = '$u1'"
}
Process {
    if (-not($MVPOauth2)) {
        Write-Verbose -Message "[$Scriptname] No Ouath2 object detected, asking for permission"
        Show-MVPOAuthWindow -url $u1
        if ($AutorizationCode) {
            $HashTable = @{
                Uri = 'https://login.live.com/oauth20_token.srf'
                Method = 'Post'
                ContentType = 'application/x-www-form-urlencoded'
                Body = 'client_id={0}&redirect_uri={1}&client_secret={2}&code={3}&grant_type=authorization_code' -f  $ClientID,$RedirectUri,$SubscriptionKey,$AutorizationCode
            }
            try {
                $r = Invoke-RestMethod @HashTable -ErrorAction Stop
                Write-Verbose -Message "[$Scriptname] Successfully got oauth 2.0 access token"
            } catch {
                Throw $_
            }
            if ($r) {
                $global:MVPOauth2 = $r | 
                Add-Member -MemberType NoteProperty -Name ValidUntil -Value ((Get-Date).AddSeconds($r.expires_in-1)) -Force -PassThru
            }
        } else {
            Write-Warning -Message "[$Scriptname] No authorization code set"
        }        
    } elseif ((Get-Date) -ge ($MVPOauth2.ValidUntil)) {

        Write-Verbose -Message "[$Scriptname] Expired Ouath2 access token detected, refreshing it"
        $HashTable = @{
            Uri = 'https://login.live.com/oauth20_token.srf'
            Method = 'Post'
            ContentType = 'application/x-www-form-urlencoded'
            Body = 'client_id={0}&grant_type=refresh_token&redirect_uri={1}&refresh_token={2}' -f $ClientID,$RedirectUri,$MVPOauth2.refresh_token
        }

        try {
            $r = Invoke-RestMethod @HashTable -ErrorAction Stop
            Write-Verbose -Message "[$Scriptname] Successfully got oauth 2.0 refresh token"
        } catch {
            Throw $_
        }
        if ($r) {
            $global:MVPOauth2 = $r | 
            Add-Member -MemberType NoteProperty -Name ValidUntil -Value ((Get-Date).AddSeconds($r.expires_in-1)) -Force -PassThru
        }        
    } else {
        Write-Verbose -Message "[$Scriptname] The current Oauth2 access token is still valid"
    }
}
}

Function Show-MVPOAuthWindow {
<#
.SYNOPSIS
    Function to show the Microsoft Authentication window
.NOTES
    https://github.com/lazywinadmin/MVP
    
    #Credit to https://raw.githubusercontent.com/1RedOne/PSWordPress/master/Private/Show-oAuthWindow.ps1
#>
    [CmdletBinding()]
    Param(
        [Uri]$url
    )
    Process {

        $Scriptname = (Get-Variable -name MyInvocation -Scope 0 -ValueOnly).MyCommand

        try {
            Write-Verbose -Message "[$ScriptName] Load assembly System.Windows.Forms"
            Add-Type -AssemblyName System.Windows.Forms -ErrorAction Stop

            Write-Verbose -Message "[$ScriptName] Create Form"
            $form = New-Object -TypeName System.Windows.Forms.Form -Property @{Width=440;Height=640}

            Write-Verbose -Message "[$ScriptName] Create Web browser"
            $web  = New-Object -TypeName System.Windows.Forms.WebBrowser -Property @{Width=420;Height=600;Url=$url}
            # define $uri in the immediate parent scope: 1
            Write-Verbose -Message "[$ScriptName] Define DocumentCompleted scriptblock"
            $DocComp  = {
                $global:uri = $web.Url.AbsoluteUri
                if ($global:uri -match 'error=[^&]*|code=[^&]*') {
                    $form.Close()
                }
            }
            $web.ScriptErrorsSuppressed = $true
            $web.Add_DocumentCompleted($DocComp)
            $form.Controls.Add($web)
            $form.Add_Shown({$form.Activate()})

            Write-Verbose -Message "[$ScriptName] Show Dialog"
            $null = $form.ShowDialog()
            # set a the autorization code globally
            $global:AutorizationCode = ([regex]'^\?code=(?<code>.+)&lc=\d{1,10}$').Matches(([uri]$uri).query).Groups |
                Select-Object -Last 1 -Expand value
            if ($global:AutorizationCode) {
                Write-Verbose -Message "[$ScriptName] Successfully got authorization code $($AutorizationCode)"
            } else {
                Write-Error "[$ScriptName] Authorization code not catched"
            }
        } catch {
            $PSCmdlet.ThrowTerminatingError($_)
        }
    }
}
