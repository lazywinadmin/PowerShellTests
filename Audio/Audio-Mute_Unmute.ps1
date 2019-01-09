$obj = new-object -com wscript.shell
$obj.SendKeys([char]173)#mute/unmute
$obj.SendKeys([char]174)#decrease (if sound is muted, it re-enable it)
$obj.SendKeys([char]175)#increase (if sound is muted, it re-enable it)
$obj.SendKeys([char]176)#next song
$obj.SendKeys([char]177)#previous/back song
$obj.SendKeys([char]179)#start/stop