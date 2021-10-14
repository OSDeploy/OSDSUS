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
        #Filter by Catalog Property
        [Parameter(Position = 0)]
        [ValidateSet(
            'All',
            'FeatureUpdate',
            'Office',
            'Office 2010 32-Bit',
            'Office 2010 64-Bit',
            'Office 2013 32-Bit',
            'Office 2013 64-Bit',
            'Office 2016 32-Bit',
            'Office 2016 64-Bit',
            'OSDBuilder',
            'OSDUpdate',
            'Windows',
            'WindowsClient',
            'Windows 10',
            'Windows 11',
            'Windows 10 Dynamic Update',
            'Windows 11 Dynamic Update',
            'Windows 7',
            'WindowsServer',
            'Windows Server 2016',
            'Windows Server 2019',
            'Windows Server'
        )]
        [Alias('Format')]
        [string]$Catalog = 'All',

        #Filter by UpdateArch Property
        [ValidateSet('x64','x86')]
        [string]$UpdateArch,

        #Filter by UpdateBuild Property
        [ValidateSet(1507,1511,1607,1703,1709,1803,1809,1903,1909,2004,'20H2','21H1','21H2')]
        [string]$UpdateBuild,

        #Filter by UpdateGroup Property
        [ValidateSet('AdobeSU','DotNet','DotNetCU','LCU','Optional','SSU')]
        [string]$UpdateGroup,

        #Filter by UpdateOS Property
        [ValidateSet('Windows 10','Windows 11','Windows Server','Windows Server 2016','Windows Server 2019')]
        [string]$UpdateOS,

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
    #===================================================================================================
    #   Catalogs
    #===================================================================================================
    $OSDSUSCatalogs = Get-ChildItem -Path "$OSDSUSCatalogPath\*" -Include "*.xml" -Recurse | Select-Object -Property *

    switch ($Catalog) {
        'Enablement'                    {$OSDSUSCatalogs = $OSDSUSCatalogs | Where-Object {$_.BaseName -match 'Enablement'}}
        'FeatureUpdate'                 {$OSDSUSCatalogs = $OSDSUSCatalogs | Where-Object {$_.BaseName -match 'FeatureUpdate'}}
        'Office'                        {$OSDSUSCatalogs = $OSDSUSCatalogs | Where-Object {$_.BaseName -match 'Office'}}
        'Office 2010 32-Bit'            {$OSDSUSCatalogs = $OSDSUSCatalogs | Where-Object {$_.BaseName -match 'Office 2010'}}
        'Office 2010 64-Bit'            {$OSDSUSCatalogs = $OSDSUSCatalogs | Where-Object {$_.BaseName -match 'Office 2010'}}
        'Office 2013 32-Bit'            {$OSDSUSCatalogs = $OSDSUSCatalogs | Where-Object {$_.BaseName -match 'Office 2013'}}
        'Office 2013 64-Bit'            {$OSDSUSCatalogs = $OSDSUSCatalogs | Where-Object {$_.BaseName -match 'Office 2013'}}
        'Office 2016 32-Bit'            {$OSDSUSCatalogs = $OSDSUSCatalogs | Where-Object {$_.BaseName -match 'Office 2016'}}
        'Office 2016 64-Bit'            {$OSDSUSCatalogs = $OSDSUSCatalogs | Where-Object {$_.BaseName -match 'Office 2016'}}
        'Windows' {
            $OSDSUSCatalogs = $OSDSUSCatalogs | Where-Object {$_.BaseName -match 'Windows'}
            $OSDSUSCatalogs = $OSDSUSCatalogs | Where-Object {$_.BaseName -notmatch 'FeatureUpdate'}
        }
        'Windows Client' {
            $OSDSUSCatalogs = $OSDSUSCatalogs | Where-Object {$_.BaseName -match 'Windows'}
            $OSDSUSCatalogs = $OSDSUSCatalogs | Where-Object {$_.BaseName -notmatch 'Server'}
            $OSDSUSCatalogs = $OSDSUSCatalogs | Where-Object {$_.BaseName -notmatch 'Dynamic Update'}
            $OSDSUSCatalogs = $OSDSUSCatalogs | Where-Object {$_.BaseName -notmatch 'FeatureUpdate'}
        }
        'Windows 10' {
            $OSDSUSCatalogs = $OSDSUSCatalogs | Where-Object {$_.BaseName -match 'Windows 10'}
            $OSDSUSCatalogs = $OSDSUSCatalogs | Where-Object {$_.BaseName -notmatch 'Dynamic Update'}
            $OSDSUSCatalogs = $OSDSUSCatalogs | Where-Object {$_.BaseName -notmatch 'FeatureUpdate'}
        }
        'Windows 11' {
            $OSDSUSCatalogs = $OSDSUSCatalogs | Where-Object {$_.BaseName -match 'Windows 11'}
            $OSDSUSCatalogs = $OSDSUSCatalogs | Where-Object {$_.BaseName -notmatch 'Dynamic Update'}
            $OSDSUSCatalogs = $OSDSUSCatalogs | Where-Object {$_.BaseName -notmatch 'FeatureUpdate'}
        }
        'Windows 10 Dynamic Update'     {$OSDSUSCatalogs = $OSDSUSCatalogs | Where-Object {$_.BaseName -eq $Catalog}}
        'Windows 11 Dynamic Update'     {$OSDSUSCatalogs = $OSDSUSCatalogs | Where-Object {$_.BaseName -eq $Catalog}}
        'Windows Server 2016'           {$OSDSUSCatalogs = $OSDSUSCatalogs | Where-Object {$_.BaseName -match $Catalog}}
        'Windows Server 2019'           {$OSDSUSCatalogs = $OSDSUSCatalogs | Where-Object {$_.BaseName -match $Catalog}}

        'OSDUpdate'                             {
            $OSDSUSCatalogs = $OSDSUSCatalogs | Where-Object {$_.BaseName -notmatch 'FeatureUpdate'}
        }

        'OSDBuilder' {
            $OSDSUSCatalogs = $OSDSUSCatalogs | Where-Object {$_.BaseName -match 'Windows'}
            $OSDSUSCatalogs = $OSDSUSCatalogs | Where-Object {$_.BaseName -notmatch 'FeatureUpdate'}

        }
        'WindowsClient' {
            $OSDSUSCatalogs = $OSDSUSCatalogs | Where-Object {$_.BaseName -match 'Windows'}
            $OSDSUSCatalogs = $OSDSUSCatalogs | Where-Object {$_.BaseName -notmatch 'Server'}
            $OSDSUSCatalogs = $OSDSUSCatalogs | Where-Object {$_.BaseName -notmatch 'Dynamic Update'}
            $OSDSUSCatalogs = $OSDSUSCatalogs | Where-Object {$_.BaseName -notmatch 'FeatureUpdate'}
        }
        'Windows Server' {
            $OSDSUSCatalogs = $OSDSUSCatalogs | Where-Object {$_.BaseName -match $Catalog}
        }
        'WindowsServer' {
            $OSDSUSCatalogs = $OSDSUSCatalogs | Where-Object {$_.BaseName -match 'Windows Server'}
            $OSDSUSCatalogs = $OSDSUSCatalogs | Where-Object {$_.BaseName -notmatch 'Dynamic Update'}
        }
    }
    #===================================================================================================
    #   Update Information
    #===================================================================================================
    if (!($Silent.IsPresent)) {
        Write-Verbose "OSDSUS $OSDSUSVersion $Catalog http://osdsus.osdeploy.com/release" -Verbose
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
    
    if ($Catalog -match 'Office') {
        if ($Catalog -match '32-Bit') {
            $OSDSUS = $OSDSUS | Where-Object {$_.Catalog -match '32-Bit'}
        }
        if ($Catalog -match '64-Bit') {
            $OSDSUS = $OSDSUS | Where-Object {$_.Catalog -match '64-Bit'}
        }
    }
    #===================================================================================================
    #   Filter
    #===================================================================================================
    if ($UpdateArch) {$OSDSUS = $OSDSUS | Where-Object {$_.UpdateArch -eq $UpdateArch}}
    if ($UpdateBuild) {$OSDSUS = $OSDSUS | Where-Object {$_.UpdateBuild -eq $UpdateBuild}}
    if ($UpdateGroup) {$OSDSUS = $OSDSUS | Where-Object {$_.UpdateGroup -eq $UpdateGroup}}
    if ($UpdateOS) {$OSDSUS = $OSDSUS | Where-Object {$_.Catalog -match $UpdateOS}}
    #===================================================================================================
    #   Sorting
    #===================================================================================================
    #$OSDSUS = $OSDSUS | Sort-Object -Property @{Expression = {$_.CreationDate}; Ascending = $false}, Size -Descending
    $OSDSUS = $OSDSUS | Sort-Object -Property CreationDate -Descending
    if ($Catalog -eq 'FeatureUpdate') {$OSDSUS = $OSDSUS | Sort-Object -Property Title}
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
