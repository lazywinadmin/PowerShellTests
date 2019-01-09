#https://core.telegram.org/bots/api#available-types

$t="secret"
$chatId='chatid'

invoke-restmethod "https://api.telegram.org/bot$t/getMe" -Body @{offset=0}
invoke-restmethod "https://api.telegram.org/bot$t/Sendmessage" -Body @{chat_id=$chatId; text="Hello from PowerShell"}





$botkey = ""

$getMeLink = "https://api.telegram.org/bot$botkey/getMe"
$sendMessageLink = "https://api.telegram.org/bot$botkey/sendMessage"
$forwardMessageLink = "https://api.telegram.org/bot$botkey/forwardMessage"
$sendPhotoLink = "https://api.telegram.org/bot$botkey/sendPhoto"
$sendAudioLink = "https://api.telegram.org/bot$botkey/sendAudio"
$sendDocumentLink = "https://api.telegram.org/bot$botkey/sendDocument"
$sendStickerLink = "https://api.telegram.org/bot$botkey/sendSticker"
$sendVideoLink = "https://api.telegram.org/bot$botkey/sendVideo"
$sendLocationLink = "https://api.telegram.org/bot$botkey/sendLocation"
$sendChatActionLink = "https://api.telegram.org/bot$botkey/sendChatAction"
$getUserProfilePhotosLink = "https://api.telegram.org/bot$botkey/getUserProfilePhotos"
$getUpdatesLink = "https://api.telegram.org/bot$botkey/getUpdates"
$setWebhookLink = "https://api.telegram.org/bot$botkey/setWebhook"

$offset = 0
write-host $botkey

while($true) {
	$json = Invoke-WebRequest -Uri $getUpdatesLink -Body @{offset=$offset} | ConvertFrom-Json
	Write-Host $json
	Write-Host $json.ok
	$l = $json.result.length
	$i = 0
	Write-Host $json.result
	Write-Host $json.result.length
	while ($i -lt $l) {
		$offset = $json.result[$i].update_id + 1
		Write-Host "New offset: $offset"
		Write-Host $json.result[$i].message
		$i++
	}
	Start-Sleep -s 2
}



function Send-TeleMessage([string] $BotKey , [array] $ChatIDs , [string] $Message)
{
    $sendMsgLink = "https://api.telegram.org/bot$BotKey/sendMessage"
    foreach ($ID in $ChatIDs)
    {        
        try
        {
            
            $ExecuteInvokeWeb = Invoke-WebRequest -Uri "$sendMsgLink" -Method Post -ContentType "application/json;charset=utf-8" -Body (ConvertTo-Json -Compress -InputObject @{chat_id=$ID; text="$Message"}) -ErrorAction SilentlyContinue
            $Status = (ConvertFrom-Json -InputObject $ExecuteInvokeWeb.Content)
            if($Status.ok){Write-Host "Message successfully sent to Chat ID : $ID (Type : $($Status.result.chat.type))" -ForegroundColor Green}
        }
        catch [Exception]
        {
            $exception = $_.Exception.ToString().Split(".")[2]
            Write-Host "Message failed to send at Chat ID : $ID ($exception)" -ForegroundColor Red
        }
    }
}