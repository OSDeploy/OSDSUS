$XmlFiles = Get-ChildItem -Path $PSScriptRoot *.xml | Where-Object {$_.Name -Match 'Windows'} | Select-Object BaseName, Name, DirectoryName, FullName

foreach ($XmlFile in $XmlFiles) {
    $XmlContent = Import-Clixml $XmlFile.FullName | Sort-Object Hash | Out-GridView -PassThru -Title "$($XmlFile.FullName)"
    Pause
    $XmlContent | Export-Clixml "$PSScriptRoot\$($XmlFile.BaseName) $(Get-Random).xml"
    
}