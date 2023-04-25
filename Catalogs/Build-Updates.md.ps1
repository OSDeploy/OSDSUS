Import-Module OSDSUS -Force
$AllOSDUpdates = @()
$AllUpdateCatalogs = Get-ChildItem -Path "$PSScriptRoot\*" -Include '*.xml' -Recurse
foreach ($UpdateCatalog in $AllUpdateCatalogs) {$AllOSDUpdates += Import-Clixml -Path "$($UpdateCatalog.FullName)"}

$AllOSDUpdates = $AllOSDUpdates | Select-Object -Property * | Sort-Object -Property Title -Unique | Sort-Object CreationDate -Descending #| Out-GridView -PassThru -Title "All OSDUpdates"
Write-Host ""
$AllOSDUpdates | Select-Object -Property CreationDate, KBNumber, Title | Sort-Object @{Expression = {$_.CreationDate}; Ascending = $false}, KBNumber, Title | Out-File C:\Users\osdcloud\Documents\GitHub\OSDSUS\UPDATES.md