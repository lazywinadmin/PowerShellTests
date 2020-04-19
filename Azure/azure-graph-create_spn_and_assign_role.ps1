$tenantId="<tenantid>" #replace with your tenant ID

$authBody=@{
    client_id="<client_id>" #replace with your client ID
    client_secret="<client_secret>" #replace with your client secret
    scope="https://graph.microsoft.com/.default"
    grant_type="client_credentials"
}


$uri="https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"

$accessToken=Invoke-WebRequest -Uri $uri -ContentType "application/x-www-form-urlencoded" -Body $authBody -Method Post -ErrorAction Stop

$accessToken=$accessToken.content | ConvertFrom-Json

# $authHeader = @{
#     'Content-Type'='application/json'
#     'Authorization'="Bearer " + $accessToken.access_token
#     'ExpiresOn'=$accessToken.expires_in
# }
$token=$accessToken.access_token
<#
    Now you're ready to use the Graph API
#>



# Permissions reference
#  https://docs.microsoft.com/en-us/graph/permissions-reference
#https://docs.microsoft.com/en-us/graph/api/serviceprincipal-list?view=graph-rest-beta&tabs=http

#################
# LIST SP
################
# Needs Permission:
# Microsoft Graph/Application Permissions/Application/application.read.all
$uri = "https://graph.microsoft.com/beta/servicePrincipals"

# Run Graph API query
#$query = Invoke-WebRequest -Method $method -Uri $uri -ContentType "application/json" -Headers @{Authorization = "Bearer $token"} -ErrorAction Stop
$q=Invoke-RestMethod -Method Get -Uri $uri -ContentType "application/json" -Headers @{Authorization = "Bearer $token"}
$q.value | select serviceprincipalNames,serviceprincipalType|fl
$q.value | ? {$_.displayname -like 'azure-cli*'}

#################
# LIST Applications (same permissions as above)
################
# Needs Permission:
# Microsoft Graph/Application Permissions/Application/application.read.all
$uri = "https://graph.microsoft.com/beta/applications"

# Run Graph API query
#$query = Invoke-WebRequest -Method $method -Uri $uri -ContentType "application/json" -Headers @{Authorization = "Bearer $token"} -ErrorAction Stop
$q=Invoke-RestMethod -Method Get -Uri $uri -ContentType "application/json" -Headers @{Authorization = "Bearer $token"}
$q.value | select serviceprincipalNames,serviceprincipalType|fl
$q.value | ? {$_.displayname -like 'azure-cli*'}

#################
# GET Application
################
# Needs Permission:
# Microsoft Graph/Application Permissions/Application/application.read.all
$uri = "https://graph.microsoft.com/beta/applications/<id>" ######################################

# Run Graph API query
#$query = Invoke-WebRequest -Method $method -Uri $uri -ContentType "application/json" -Headers @{Authorization = "Bearer $token"} -ErrorAction Stop
$q=Invoke-RestMethod -Method Get -Uri $uri -ContentType "application/json" -Headers @{Authorization = "Bearer $token"}

<#
@odata.context            : https://graph.microsoft.com/beta/$metadata#applications/$entity
id                        : <id>
deletedDateTime           :
addIns                    : {}
appId                     : <appid>
applicationTemplateId     :
identifierUris            : {http://###################################}
createdDateTime           : 2/22/20 2:17:59 AM
displayName               : SubOwnerSP
isDeviceOnlyAuthSupported :
isFallbackPublicClient    :
groupMembershipClaims     :
optionalClaims            :
orgRestrictions           : {}
publisherDomain           : #######################################
signInAudience            : #########################################
tags                      : {}
tokenEncryptionKeyId      :
verifiedPublisher         : @{displayName=; verifiedPublisherId=; addedDateTime=}
spa                       : @{redirectUris=System.Object[]}
api                       : @{requestedAccessTokenVersion=; acceptMappedClaims=; knownClientApplications=System.Object[]; oauth2PermissionScopes=System.Object[];
                            preAuthorizedApplications=System.Object[]; resourceSpecificApplicationPermissions=System.Object[]}
appRoles                  : {}
publicClient              : @{redirectUris=System.Object[]}
info                      : @{termsOfServiceUrl=; supportUrl=; privacyStatementUrl=; marketingUrl=; logoUrl=}
keyCredentials            : {}
parentalControlSettings   : @{countriesBlockedForMinors=System.Object[]; legalAgeGroupRule=Allow}
passwordCredentials       : {@{customKeyIdentifier=//###########==; endDateTime=2#######2:17:59 AM; keyId=#######################; startDateTime=2/22/20 2:17:59 AM;
                            secretText=; hint=; displayName=}}
requiredResourceAccess    : {}
web                       : @{redirectUris=System.Object[]; homePageUrl=https://#########################; logoutUrl=; implicitGrantSettings=}
#>


################
# Create Application
################
# https://docs.microsoft.com/en-us/graph/api/application-post-applications?view=graph-rest-beta&tabs=http#examples
# Needs Permission:
# Microsoft Graph/Application Permissions/Application/Application.ReadWrite.OwnedBy
# Microsoft Graph/Application Permissions/Application/Application.ReadWrite.All
$uri = "https://graph.microsoft.com/v1.0/applications"
$authHeader = @{
    'Content-type' = 'application/json'
    'Authorization'="Bearer $($accessToken.access_token)"
    #'ExpiresOn'=$accessToken.expires_in
}
$body = @"
{
    "displayName": "mytestapp123",

}
"@
$q=Invoke-RestMethod -Method Post -Uri $uri -Headers $authHeader -Body $body -verbose #-ContentType 'application/json'

<#
Invoke-RestMethod : {
  "error": {
    "code": "Service_ServiceUnavailable",
    "message": "Service is temporarily unavailable. Please wait and retry again.",
    "innerError": {
      "request-id": "ed0a5aaf-0a2f-422a-a4ec-d4a97e11f15c",
      "date": "2020-02-22T02:07:08"
    }
  }
}
#>

################
# Update Application
################
# https://docs.microsoft.com/en-us/graph/api/application-post-applications?view=graph-rest-beta&tabs=http#examples
# Needs Permission:
# Microsoft Graph/Application Permissions/Application/Application.ReadWrite.OwnedBy
# Microsoft Graph/Application Permissions/Application/Application.ReadWrite.All
$uri = "https://graph.microsoft.com/v1.0/applications/<id>" #objectID######################################################################
$authHeader = @{
    'Content-type' = 'application/json'
    'Authorization'="Bearer $($accessToken.access_token)"
    #'ExpiresOn'=$accessToken.expires_in
}
$body = @"
{
    "displayName": "mysubownerspn",
}
"@
Invoke-RestMethod -Method Patch -Uri $uri -Headers $authHeader -Body $body
# WORKS!

################
# Create Application (With ServicePrincipal)
################
# https://docs.microsoft.com/en-us/graph/api/application-post-applications?view=graph-rest-beta&tabs=http#examples
# Needs Permission:
# Microsoft Graph/Application Permissions/Application/Application.ReadWrite.OwnedBy
# Microsoft Graph/Application Permissions/Application/Application.ReadWrite.All
$uri = "https://graph.microsoft.com/v1.0/applications"
$authHeader = @{
    'Content-type' = 'application/json'
    'Authorization'="Bearer $($accessToken.access_token)"
    #'ExpiresOn'=$accessToken.expires_in
}
$body = @"
{
    "displayName": "mytestapp123",
    "identifierUris": [
      "https://##################.onmicrosoft.com/mytestapp123"
    ]
}
"@
$q=Invoke-RestMethod -Method Post -Uri $uri -Headers $authHeader -Body $body -verbose #-ContentType 'application/json'
$q
#Create ServicePrincipal
$uri2 = "https://graph.microsoft.com/beta/servicePrincipals"
$body2 =@"
{
    appid: "$($q.appid)"
}
"@
$q2=Invoke-RestMethod -Method Post -Uri $uri2 -Headers $authHeader -Body $body2 -verbose #-ContentType 'application/json'

# Set a password on application
/applications/{id}/addPassword
$uri3 = "https://graph.microsoft.com/beta/applications/$($q.id)/addPassword"
$body3 =@"
{}
"@
$q3=Invoke-RestMethod -Method Post -Uri $uri3 -Headers $authHeader -Body $body3 -verbose #-ContentType 'application/json'
<#
@odata.context      : https://graph.microsoft.com/beta/$metadata#microsoft.graph.passwordCredential
customKeyIdentifier :
endDateTime         : 2/28/22 1:55:35 AM
keyId               : ###################################
startDateTime       : 2/28/20 1:55:35 AM
secretText          : #####################################
hint                : #####################################
displayName         :

#>

# Get Enterprise Application ObjectID
#https://graph.microsoft.com/beta/servicePrincipals?$filter=tags/any(t:t eq 'WindowsAzureActiveDirectoryIntegratedApp')
$uri4 = "https://graph.microsoft.com/beta/serviceprincipals?`$filter=startswith(displayname,'$($q.displayname)')"

$q4=Invoke-RestMethod -Method get -Uri $uri4 -Headers $authHeader -verbose #-ContentType 'application/json'

$q4.value | select *id* # id is Enterprise Application ID
$q | select *id* # id is App registration ID
$q2 | select *id* # id is Enterprise Application ID

<#
id                                  : ###########################################
deletedDateTime                     :
accountEnabled                      : True
alternativeNames                    : {}
appDisplayName                      : Access IoT Hub Device Provisioning Service
appId                               : ##############################################
applicationTemplateId               :
appOwnerOrganizationId              : ################################################
appRoleAssignmentRequired           : False
displayName                         : Access IoT Hub Device Provisioning Service
errorUrl                            :
homepage                            :
loginUrl                            :
logoutUrl                           :
notificationEmailAddresses          : {}
preferredSingleSignOnMode           :
preferredTokenSigningKeyEndDateTime :
preferredTokenSigningKeyThumbprint  :
publisherName                       : Microsoft Services
replyUrls                           : {}
samlMetadataUrl                     :
samlSingleSignOnSettings            :
servicePrincipalNames               : {###################################, https://azure-devices-provisioning.net}
servicePrincipalType                : Application
signInAudience                      : ###########################
tags                                : {}
tokenEncryptionKeyId                :
verifiedPublisher                   : @{displayName=; verifiedPublisherId=; addedDateTime=}
addIns                              : {}
api                                 : @{resourceSpecificApplicationPermissions=System.Object[]}
appRoles                            : {}
info                                : @{termsOfServiceUrl=; supportUrl=; privacyStatementUrl=; marketingUrl=; logoUrl=}
keyCredentials                      : {}
publishedPermissionScopes           : {@{adminConsentDescription=Access to IoT DPS; adminConsentDisplayName=Access to IoT DPS; id=############################; isEnabled=True;
                                      type=User; userConsentDescription=Access to IoT DPS; userConsentDisplayName=Access to IoT DPS; value=user_impersonation}}
passwordCredentials                 : {}

id                                  : #########################################
deletedDateTime                     :
accountEnabled                      : True
alternativeNames                    : {}
appDisplayName                      : Azure Resource Graph
appId                               : #######################################
applicationTemplateId               :
appOwnerOrganizationId              : ########################################
appRoleAssignmentRequired           : False
displayName                         : Azure Resources Topology
errorUrl                            :
homepage                            :
loginUrl                            :
logoutUrl                           :
notificationEmailAddresses          : {}
preferredSingleSignOnMode           :
preferredTokenSigningKeyEndDateTime :
preferredTokenSigningKeyThumbprint  :
publisherName                       : Microsoft Services
replyUrls                           : {https://gov-rp-eus-art.eastus.cloudapp.azure.com}
samlMetadataUrl                     :
samlSingleSignOnSettings            :
servicePrincipalNames               : {###############################################}
servicePrincipalType                : Application
signInAudience                      : #########################################
tags                                : {}
tokenEncryptionKeyId                :
verifiedPublisher                   : @{displayName=; verifiedPublisherId=; addedDateTime=}
addIns                              : {}
api                                 : @{resourceSpecificApplicationPermissions=System.Object[]}
appRoles                            : {}
info                                : @{termsOfServiceUrl=; supportUrl=; privacyStatementUrl=; marketingUrl=; logoUrl=}
keyCredentials                      : {}
publishedPermissionScopes           : {}
passwordCredentials                 : {}

#>


# list only Enterprise Applications
#https://graph.microsoft.com/beta/servicePrincipals?$filter=tags/any(t:t eq 'WindowsAzureActiveDirectoryIntegratedApp')
#  https://stackoverflow.com/questions/55591893/is-there-any-way-to-get-master-list-of-all-apps-through-graph-explorer-api


# Add a password on servicePrincipal
/applications/{id}/addPassword
$uri5 = "https://graph.microsoft.com/beta/serviceprincipals/$($q2.id)/addPassword"
$body5 =@"
{}
"@
$q5=Invoke-RestMethod -Method Post -Uri $uri5 -Headers $authHeader -Body $body5 -verbose #-ContentType 'application/json'


# Remove a password on servicePrincipal
$uri6 = "https://graph.microsoft.com/beta/serviceprincipals/$($q2.id)/addPassword"
$body6 =@"
{}
"@
$q6=Invoke-RestMethod -Method Post -Uri $uri6 -Headers $authHeader -Body $body6 -verbose #-ContentType 'application/json'




## Testing with the new SPN we just created

$tenantId2="<tenantid>" #replace with your tenant ID

$authBody2=@{
    client_id="<clientid>" #appid of the spn
    client_secret="<secret>" #this is coming from the addpassword output
    scope="https://graph.microsoft.com/.default"
    grant_type="client_credentials"
}


$urii="https://login.microsoftonline.com/$tenantId2/oauth2/v2.0/token"

$accessToken2=Invoke-WebRequest -Uri $urii -ContentType "application/x-www-form-urlencoded" -Body $authBody2 -Method Post -ErrorAction Stop

$accessToken2=$accessToken2.content | ConvertFrom-Json
$authHeaderrr = @{
    'Content-type' = 'application/json'
    'Authorization'="Bearer $($accessToken2.access_token)"
    #'ExpiresOn'=$accessToken.expires_in
}
$uriii = "https://graph.microsoft.com/beta/serviceprincipals"

$qq=Invoke-RestMethod -Method get -Uri $uriii -Headers $authHeaderrr -verbose #-ContentType 'application/json'
$qq.value

#worked :)




#####################
# ASSIGN ROLE OWNER On SUB
##################
# https://docs.microsoft.com/en-us/azure/role-based-access-control/role-assignments-rest
$myscope='subscriptions/<sub_id>'
$RoleAssignmentName = [guid]::NewGuid().guid
$roleDefinitionId = '<role_ownerId>' #Get-AzRoleDefinition -Name Owner
$SPPrincipalID='<id>' #Get-AzADApplication -DisplayName 'subOwnerSP'
$uri = "https://management.azure.com/$myscope/providers/Microsoft.Authorization/roleAssignments/$($RoleAssignmentName)?api-version=2015-07-01"
$authHeader = @{
    'Content-type' = 'application/json'
    'Authorization'="Bearer $($accessToken.access_token)"
    #'ExpiresOn'=$accessToken.expires_in
}
$body = @"
{
    "properties": {
      "roleDefinitionId": "/$myscope/providers/Microsoft.Authorization/roleDefinitions/$roleDefinitionId",
      "principalId": "$($SPprincipalId)"
    }
  }
"@
Invoke-RestMethod -Method PUT -Uri $uri -Headers $authHeader -Body $body


###
# GET ROLE DEFINITION LIST: https://docs.microsoft.com/en-us/rest/api/authorization/roledefinitions/list
###

###
# LIST ROLE ASSIGNMENTS
###
#https://docs.microsoft.com/en-us/azure/role-based-access-control/role-assignments-list-rest
#https://management.azure.com/{scope}/providers/Microsoft.Authorization/roleAssignments?api-version=2015-07-01&$filter={filter}
$myscope='subscriptions/<sub_id>'
$uri = "https://management.azure.com/$($myscope)/providers/Microsoft.Authorization/roleAssignments?api-version=2015-07-01" #&$filter={filter}"
$uri = "https://management.azure.com/$($myscope)/resourceGroups?api-version=2014-04-01"
Invoke-RestMethod -Method GET -Uri $uri -Headers @{ "Authorization" = "Bearer $($accessToken.access_token)"}