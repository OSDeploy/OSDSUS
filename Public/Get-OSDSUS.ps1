<#
.SYNOPSIS
Returns an Array of Microsoft Updates

.DESCRIPTION
Returns an Array of Microsoft Updates contained in the local WSUS Catalogs

.LINK
https://osdsus.osdeploy.com/module/functions/get-osdsus

.PARAMETER GridView
Displays the results in GridView with -PassThru

.PARAMETER Silent
Hide the Current Update Date information
#>
function Get-OSDSUS {
    [CmdletBinding()]
    PARAM (
        [switch]$GridView,
        [switch]$Silent
    )
    #===================================================================================================
    #   Update Information
    #===================================================================================================
    $OSDSUSCatalogs = "$($MyInvocation.MyCommand.Module.ModuleBase)\Catalogs"
    $OSDSUSVersion = $($MyInvocation.MyCommand.Module.Version)

    if (!($Silent.IsPresent)) {
        Write-Verbose "OSDSUS $OSDSUSVersion" -Verbose
        Write-Verbose "http://osdsus.osdeploy.com/release" -Verbose
        Write-Verbose 'Gathering Updates ...' -Verbose
    }
    #===================================================================================================
    #   Variables
    #===================================================================================================
    $OSDSUS = @()
    #===================================================================================================
    #   UpdateCatalogs
    #===================================================================================================
    $OSDSUSCatalogs = Get-ChildItem -Path "$OSDSUSCatalogs\*" -Include "*.xml" -Recurse
    #===================================================================================================
    #   Import Catalog XML Files
    #===================================================================================================
    foreach ($OSDSUSCatalog in $OSDSUSCatalogs) {
        $OSDSUS += Import-Clixml -Path "$($OSDSUSCatalog.FullName)"
    }
    #===================================================================================================
    #   Standard Filters
    #===================================================================================================
    $OSDSUS = $OSDSUS | Where-Object {$_.FileName -notlike "*.exe"}
    $OSDSUS = $OSDSUS | Where-Object {$_.FileName -notlike "*.psf"}
    $OSDSUS = $OSDSUS | Where-Object {$_.FileName -notlike "*.txt"}
    $OSDSUS = $OSDSUS | Where-Object {$_.FileName -notlike "*delta.exe"}
    $OSDSUS = $OSDSUS | Where-Object {$_.FileName -notlike "*express.cab"}
    #===================================================================================================
    #   Sorting
    #===================================================================================================
    #$OSDSUS = $OSDSUS | Sort-Object -Property @{Expression = {$_.CreationDate}; Ascending = $false}, Size -Descending
    $OSDSUS = $OSDSUS | Sort-Object -Property CreationDate -Descending
    #===================================================================================================
    #   GridView
    #===================================================================================================
    if ($GridView.IsPresent) {
        $OSDSUS = $OSDSUS | Out-GridView -PassThru -Title 'Select Updates to Return'
    }
    #===================================================================================================
    #   Return
    #===================================================================================================
    Return $OSDSUS
}
