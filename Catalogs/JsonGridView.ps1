$AllFiles = @()
$Results = @()
$AllFiles = Get-ChildItem -Path $PSScriptRoot *.json -Recurse

foreach ($Item in $AllFiles) {
    $Results += Get-Content $Item.FullName -Raw | ConvertFrom-Json
}

$Results | ogv