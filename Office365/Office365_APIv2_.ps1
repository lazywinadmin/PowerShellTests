$ApplicationID = 'App ID'
$Secret = 'Secret :)'
$Tenant = 'lz.onmicrosoft.com'
$RedirectUri = 'https://localhost/'
$ApplicationName = 'PowerShell_Office365'
$MyAccount = 'myaccount@contoso.onmicrosoft.com'

$secpasswd = ConvertTo-SecureString -string $Secret -AsPlainText -Force
$mycreds = New-Object System.Management.Automation.PSCredential ($ApplicationID, $secpasswd)

# Download the module from the PSGallery 
Install-Module -Name PSMSGraph -Scope CurrentUser -Repository psgallery -verbose 
Import-Module -Name PSMSGraph

#In the credential prompt, provide your application's Client ID as the username and Client Secret as the password

$GraphAppParams = @{
    Name = $ApplicationName
    ClientCredential = $mycreds
    RedirectUri = $RedirectUri
    Tenant = $Tenant
}
$GraphApp = New-GraphApplication @GraphAppParams
# This will prompt you to log in with your O365/Azure credentials. 
# This is required at least once to authorize the application to act on behalf of your account
# The username and password is not passed back to or stored by PowerShell.
$AuthCode = $GraphApp | Get-GraphOauthAuthorizationCode 

$GraphAccessToken = Get-GraphOauthAccessToken -AuthenticationCode $AuthCode
$GraphAccessToken | Export-GraphOAuthAccessToken -Path 'C:\Users\fxavi\OneDrive\Scripts\Github\PowerShellTests\Office365\AccessToken.XML'

# Retrieve current profile
Invoke-GraphRequest -AccessToken $GraphAccessToken -Uri 'https://graph.microsoft.com/v1.0/me'
Invoke-GraphRequest -AccessToken $GraphAccessToken -Uri "https://graph.microsoft.com/v1.0/me/" |select -expand contentobject

# Retrieve specific user
Invoke-GraphRequest -AccessToken $GraphAccessToken -Uri "https://graph.microsoft.com/v1.0/users/$MyAccount"

invok

# Calendar
Invoke-GraphRequest -AccessToken $GraphAccessToken -Uri "https://graph.microsoft.com/v1.0/me/calendars"

# User Events
Invoke-GraphRequest -AccessToken $GraphAccessToken -Uri "https://graph.microsoft.com/v1.0/me/events" #calendarview?startDateTime=$(Get-Date)&endDateTime=$((Get-Date).AddDays(7))"
Invoke-GraphRequest -AccessToken $GraphAccessToken -Uri "https://graph.microsoft.com/v1.0/users/$MyAccount/events"
