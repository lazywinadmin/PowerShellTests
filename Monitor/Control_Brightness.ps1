$monitor = Get-WmiObject -ns root/wmi -class wmiMonitorBrightNessMethods
$monitor.WmiSetBrightness(80, 10)
$monitor.WmiSetBrightness(80, 30)
$monitor.WmiSetBrightness(80, 40)
$monitor.WmiSetBrightness(80, 45)