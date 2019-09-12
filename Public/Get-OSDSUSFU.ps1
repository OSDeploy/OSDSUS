<#
.SYNOPSIS
Returns an Array of Microsoft Updates

.DESCRIPTION
Returns an Array of Microsoft Updates contained in the local WSUS Catalogs

.LINK
https://osdsus.osdeploy.com/module/functions/get-osdsusfu

.PARAMETER GridView
Displays the results in GridView with -PassThru

.PARAMETER Silent
Hide the Current Update Date information
#>
function Get-OSDSUSFU {
    [CmdletBinding()]
    PARAM (
        [switch]$GridView,
        [switch]$Silent
    )
    #===================================================================================================
    #   Update Information
    #===================================================================================================
    $OSDSUSCatalogs = "$($MyInvocation.MyCommand.Module.ModuleBase)\CatalogsFU"
    $OSDSUSVersion = $($MyInvocation.MyCommand.Module.Version)

    if (!($Silent.IsPresent)) {
        Write-Verbose "OSDSUSFU $OSDSUSVersion" -Verbose
        Write-Verbose "http://osdsus.osdeploy.com/release" -Verbose
        Write-Verbose 'Gathering Updates ...' -Verbose
    }
    #===================================================================================================
    #   Variables
    #===================================================================================================
    $OSDSUSFU = @()
    #===================================================================================================
    #   UpdateCatalogs
    #===================================================================================================
    $OSDSUSCatalogs = Get-ChildItem -Path "$OSDSUSCatalogs\*" -Include "*.xml" -Recurse
    #===================================================================================================
    #   Import Catalog XML Files
    #===================================================================================================
    foreach ($OSDSUSCatalog in $OSDSUSCatalogs) {
        $OSDSUSFU += Import-Clixml -Path "$($OSDSUSCatalog.FullName)"
    }
    #===================================================================================================
    #   Sorting
    #===================================================================================================
    #$OSDSUSFU = $OSDSUSFU | Sort-Object -Property @{Expression = {$_.CreationDate}; Ascending = $false}, Size -Descending
    $OSDSUSFU = $OSDSUSFU | Sort-Object -Property CreationDate -Descending
    #===================================================================================================
    #   GridView
    #===================================================================================================
    if ($GridView.IsPresent) {
        $OSDSUSFU = $OSDSUSFU | Out-GridView -PassThru -Title 'Select Updates to Return'
    }
    #===================================================================================================
    #   Return
    #===================================================================================================
    Return $OSDSUSFU
}
