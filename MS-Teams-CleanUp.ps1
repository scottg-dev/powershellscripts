$TeamsCacheFolder = 'C:\Users\P009197D\AppData\Roaming\Microsoft\Teams'

$FolderLocations = @(
("$TeamsCacheFolder\Application Cache\"),
("$TeamsCacheFolder\Application Cache\Cache\"),
("$TeamsCacheFolder\databases\"),
("$TeamsCacheFolder\GPUCache\"),
("$TeamsCacheFolder\IndexedDB\"),
("$TeamsCacheFolder\Local Storage\"), 
("$TeamsCacheFolder\tmp\"))
$Items = "*.*"
foreach ($value in $FolderLocations) 
{
Remove-Item "$value\$Items"
#New-Item -Path $value -Name "test1.txt" -ItemType "file" -Value "This is a text string" -Force
}

#Remove-Item "$TeamsCacheFolder\tmp\$Items"