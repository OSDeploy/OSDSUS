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
        [Parameter(Position = 0)]
        [ValidateSet('Office','Windows','FeatureUpdate','OSDUpdate')]
        [string]$Format,
        [switch]$GridView,
        [switch]$Silent
    )
    #===================================================================================================
    #   Defaults
    #===================================================================================================
    $OSDSUSCatalogPath = "$($MyInvocation.MyCommand.Module.ModuleBase)\Catalogs"
    $OSDSUSVersion = $($MyInvocation.MyCommand.Module.Version)
    if (!($Format)) {$Format = 'OSDUpdate'}
    #===================================================================================================
    #   UpdateCatalogs
    #===================================================================================================

    $OSDSUSCatalogs = Get-ChildItem -Path "$OSDSUSCatalogPath\*" -Include "*.xml" -Recurse | Select-Object -Property *
    if ($Format -eq 'Office') {$OSDSUSCatalogs = $OSDSUSCatalogs | Where-Object {$_.Name -like "Office*"}}
    if ($Format -eq 'Windows') {$OSDSUSCatalogs = $OSDSUSCatalogs | Where-Object {$_.Name -like "Windows*" -and $_.Name -notmatch 'FeatureUpdate'}}
    if ($Format -eq 'FeatureUpdate') {$OSDSUSCatalogs = $OSDSUSCatalogs | Where-Object {$_.Name -match 'FeatureUpdate'}}
    if ($Format -eq 'OSDUpdate') {$OSDSUSCatalogs = $OSDSUSCatalogs | Where-Object {$_.Name -notmatch 'FeatureUpdate'}}
    #===================================================================================================
    #   Update Information
    #===================================================================================================
    if (!($Silent.IsPresent)) {
        Write-Verbose "OSDSUS $OSDSUSVersion $Format http://osdsus.osdeploy.com/release" -Verbose
    }
    #===================================================================================================
    #   Variables
    #===================================================================================================
    $OSDSUS = @()
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
