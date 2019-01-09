
$ApiKey = '<Key here>'
$MyQuery = "Bonjour Montreal"
$url = "http://api.wolframalpha.com/v1/result?i=$myquery&appid=$ApiKey"
Invoke-RestMethod -Uri $url

