# Get all the Mailbox servers
ForEach ($server in Get-MailboxServer) 
{ 
   # For each Mailbox server, get all the databases on it
   $strDB = Get-MailboxDatabase -Server $server 
   
   # For each Database, get the information from it
   ForEach ($objItem in $strDB) 
   { 
      $intUsers = ($objitem | Get-Mailbox -ResultSize Unlimited).count

      # Get the size of the database file
      $edbfilepath = $objItem.edbfilepath 
      $path = "`\`\" + $server + "`\" + $objItem.EdbFilePath.DriveName.Remove(1).ToString() + "$"+ $objItem.EdbFilePath.PathName.Remove(0,2) 
      $strDBsize = Get-ChildItem $path 
      $ReturnedObj = New-Object PSObject 
      $ReturnedObj | Add-Member NoteProperty -Name "Server\StorageGroup\Database" -Value $objItem.Identity 
      $ReturnedObj | Add-Member NoteProperty -Name "Size (GB)" -Value ("{0:n2}" -f ($strDBsize.Length/1048576KB)) 
      $ReturnedObj | Add-Member NoteProperty -Name "Size (MB)" -Value ("{0:n2}" -f ($strDBsize.Length/1024KB)) 
      $ReturnedObj | Add-Member NoteProperty -Name "User Count" -Value $intUsers 
   
      Write-Output $ReturnedObj
   }
}