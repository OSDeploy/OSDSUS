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
        #Catalog Group
        [Parameter(Position = 0)]
        [ValidateSet('Office','Windows','FeatureUpdate','OSDUpdate')]
        [string]$Format,

        #Filter by Catalog Property
        [ValidateSet(
            'Office 2010 32-Bit',
            'Office 2010 64-Bit',
            'Office 2013 32-Bit',
            'Office 2013 64-Bit',
            'Office 2016 32-Bit',
            'Office 2016 64-Bit',
            'Windows 10',
            'Windows 10 Dynamic Update',
            'Windows 7',
            'Windows Server 2012 R2',
            'Windows Server 2012 R2 Dynamic Update',
            'Windows Server 2016',
            'Windows Server 2019'
        )]
        [string]$ByCatalog,

        #Filter by UpdateArch Property
        [ValidateSet('x64','x86')]
        [string]$ByUpdateArch,

        #Filter by UpdateBuild Property
        [ValidateSet(1507,1511,1607,1703,1709,1803,1809,1903,1909)]
        [int]$ByUpdateBuild,

        #Filter by UpdateGroup Property
        [ValidateSet('AdobeSU','DotNet','DotNetCU','LCU','Optional','SSU')]
        [string]$ByUpdateGroup,

        #Filter by UpdateOS Property
        [ValidateSet('Windows 10','Windows 7','Windows Server 2012 R2','Windows Server 2016','Windows Server 2019')]
        [string]$ByUpdateOS,

        #Display the results in GridView
        [switch]$GridView,

        #Don't display the Module Information
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
    #   Filter
    #===================================================================================================
    if ($ByCatalog) {$OSDSUS = $OSDSUS | Where-Object {$_.Catalog -eq $ByCatalog}}
    if ($ByUpdateArch) {$OSDSUS = $OSDSUS | Where-Object {$_.UpdateArch -eq $ByUpdateArch}}
    if ($ByUpdateBuild) {$OSDSUS = $OSDSUS | Where-Object {$_.UpdateBuild -eq $ByUpdateBuild}}
    if ($ByUpdateGroup) {$OSDSUS = $OSDSUS | Where-Object {$_.UpdateGroup -eq $ByUpdateGroup}}
    if ($ByUpdateOS) {$OSDSUS = $OSDSUS | Where-Object {$_.UpdateOS -eq $ByUpdateOS}}
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
