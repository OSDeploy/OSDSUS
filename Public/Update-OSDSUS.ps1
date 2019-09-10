<#
.SYNOPSIS
Updates the OSDSUS PowerShell Module to the latest version

.DESCRIPTION
Updates the OSDSUS PowerShell Module to the latest version from the PowerShell Gallery

.LINK
https://OSDSUS.osdeploy.com/module/functions/update-osdsus

.Example
Update-OSDSUS
#>

function Update-OSDSUS {
    [CmdletBinding()]
    PARAM ()
    try {
        Write-Warning "Uninstall-Module -Name OSDSUS -AllVersions -Force"
        Uninstall-Module -Name OSDSUS -AllVersions -Force
    }
    catch {}

    try {
        Write-Warning "Install-Module -Name OSDSUS -Force"
        Install-Module -Name OSDSUS -Force
    }
    catch {}

    try {
        Write-Warning "Import-Module -Name OSDSUS -Force"
        Import-Module -Name OSDSUS -Force
    }
    catch {}
}