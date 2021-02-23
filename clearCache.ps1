$Folder = "%TEMP%"

#delete files in temp folder older than 30 days
Get-ChildItem $Folder -Recurse -Force -ea 0 |
? {!$_.PsIsContainer -and $_.LastWriteTime -lt (Get-Date).AddDays(-30)} |
ForEach-Object {
   $_ | del -Force
   $_.FullName | Out-File C:\log\deletedbackups.txt -Append
}

#delete empty folders and subfolders if any exist in temp folder
Get-ChildItem $Folder -Recurse -Force -ea 0 |
? {$_.PsIsContainer -eq $True} |
? {$_.getfiles().count -eq 0} |
ForEach-Object {
    $_ | del -Force
    $_.FullName | Out-File C:\log\deletedbackups.txt -Append
}
