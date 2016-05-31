function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateSet('Admin API','Tenant API','Tenant Public API','SQL Server Extension','MySQL Extension','Admin Site','Admin Authentication Site','Tenant Site','Tenant Authentication Site')]
        [System.String]
        $Role,

        [parameter(Mandatory = $true)]
        [System.String]
        $SourcePath,

        [System.String]
        $SourceFolder = '\WindowsAzurePack2013\Updates',

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $SetupCredential
    )

    $returnValue = @{
        Role = $Role
        SourcePath = $SourcePath
        SourceFolder = $SourceFolder
    }

    $returnValue
}

function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateSet('Admin API','Tenant API','Tenant Public API','SQL Server Extension','MySQL Extension','Admin Site','Admin Authentication Site','Tenant Site','Tenant Authentication Site')]
        [System.String]
        $Role,

        [parameter(Mandatory = $true)]
        [System.String]
        $SourcePath,

        [System.String]
        $SourceFolder = '\WindowsAzurePack2013\Updates',

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $SetupCredential
    )

    Import-Module $PSScriptRoot\..\..\xPDT.psm1
        
    $Path = 'msiexec.exe'
    $Path = ResolvePath $Path
    Write-Verbose "Path: $Path"

    $TempPath = [IO.Path]::GetTempPath().TrimEnd('\')
    $buildversion = '3.33.8196.14' # Update Rollup 10 https://support.microsoft.com/en-gb/kb/3158609
    $Products = (Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*,
                                  HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {![string]::IsNullOrWhiteSpace($_.DisplayName) -and $_.DisplayVersion -eq $buildversion} | Sort-Object DisplayName -Unique).DisplayName
    $Components = Get-WAPComponents -Role $Role
    foreach($Component in $Components)
    {
        $ComponentInstalled = $true
        if($ComponentInstalled)
        {
            $Componentnames = Get-WAPComponentNames -Component $Component
            $ComponentInstalled = Get-ComponentInstalled -Products $Products -ComponentNames $Componentnames
            if(!$ComponentInstalled)
            {
                $MSIPath = ResolvePath "$SourcePath\$SourceFolder\$Component.msi"
                Copy-Item -Path $MSIPath -Destination $TempPath
                $Arguments = "/q /lv $TempPath\$Component.log /i $TempPath\$Component.msi ALLUSERS=2"
                Write-Verbose "Arguments: $Arguments"
                $Process = StartWin32Process -Path $Path -Arguments $Arguments -Credential $SetupCredential
                Write-Verbose $Process
                WaitForWin32ProcessEnd -Path $Path -Arguments $Arguments -Credential $SetupCredential
                Remove-Item -Path "$TempPath\$Component.msi"
                $ComponentInstalled = Get-ComponentInstalled -Products $Products -IdentifyingNumbers $IdentifyingNumbers
            }
        }
    }

    if((Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager' -Name 'PendingFileRenameOperations' -ErrorAction SilentlyContinue) -ne $null)
    {
        $global:DSCMachineStatus = 1
    }
    else
    {
        if(!(Test-TargetResource @PSBoundParameters))
        {
            throw 'Set-TargetResouce failed'
        }
    }
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateSet('Admin API','Tenant API','Tenant Public API','SQL Server Extension','MySQL Extension','Admin Site','Admin Authentication Site','Tenant Site','Tenant Authentication Site')]
        [System.String]
        $Role,

        [parameter(Mandatory = $true)]
        [System.String]
        $SourcePath,

        [System.String]
        $SourceFolder = '\WindowsAzurePack2013\Updates',

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $SetupCredential
    )

    $result = $true
    $buildversion = '3.33.8196.14' # Update Rollup 10 https://support.microsoft.com/en-gb/kb/3158609
    $Products = (Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*,
                                  HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {![string]::IsNullOrWhiteSpace($_.DisplayName) -and $_.DisplayVersion -eq $buildversion} | Sort-Object DisplayName -Unique).DisplayName
    $Components = Get-WAPComponents -Role $Role
    foreach($Component in $Components)
    {
        if($result)
        {
            $Componentnames = Get-WAPComponentNames -Component $Component
            $ComponentInstalled = Get-ComponentInstalled -Products $Products -ComponentNames $Componentnames
            if(!$ComponentInstalled)
            {
                $result = $false
            }
        }
    }

    $result
}

function Get-WAPComponents
{
    param
    (
        [String]
        $Role
    )

    switch($Role)
    {
        'Admin API'
        {
            return @(
                'MgmtSvc-PowerShellAPI',
                'MgmtSvc-WebAppGallery',
                'MgmtSvc-Monitoring',
                'MgmtSvc-Usage',
                'MgmtSvc-AdminAPI',
                'MgmtSvc-ConfigSite'
            )
        }
        'Tenant API'
        {
            return @(
                'MgmtSvc-PowerShellAPI',
                'MgmtSvc-TenantAPI',
                'MgmtSvc-ConfigSite'
            )
        }
        'Tenant Public API'
        {
            return @(
                'MgmtSvc-PowerShellAPI',
                'MgmtSvc-TenantPublicAPI',
                'MgmtSvc-ConfigSite'
            )
        }
        'SQL Server Extension'
        {
            return @(
                'MgmtSvc-PowerShellAPI',
                'MgmtSvc-SQLServer',
                'MgmtSvc-ConfigSite'
            )
        }
        'MySQL Extension'
        {
            return @(
                'MgmtSvc-PowerShellAPI',
                'MgmtSvc-MySQL',
                'MgmtSvc-ConfigSite'
            )
        }
        'Admin Site'
        {
            return @(
                'MgmtSvc-PowerShellAPI',
                'MgmtSvc-AdminSite',
                'MgmtSvc-ConfigSite'
            )
        }
        'Admin Authentication Site'
        {
            return @(
                'MgmtSvc-PowerShellAPI',
                'MgmtSvc-WindowsAuthSite',
                'MgmtSvc-ConfigSite'
            )
        }
        'Tenant Site'
        {
            return @(
                'MgmtSvc-PowerShellAPI',
                'MgmtSvc-TenantSite',
                'MgmtSvc-ConfigSite'
            )
        }
        'Tenant Authentication Site'
        {
            return @(
                'MgmtSvc-PowerShellAPI',
                'MgmtSvc-AuthSite',
                'MgmtSvc-ConfigSite'
            )
        }
    }
}

function Get-WAPComponentNames
{
    param
    (
        [String]
        $Component
    )

    switch($Component)
    {
        'MgmtSvc-PowerShellAPI'
        {
            return 'Windows Azure Pack - PowerShell API - 2013'
        }
        'MgmtSvc-WebAppGallery'
        {
            return 'Windows Azure Pack - Web App Gallery Extension - 2013'
        }
        'MgmtSvc-Monitoring'
        {
            return 'Windows Azure Pack - Monitoring Extension - 2013'
        }
        'MgmtSvc-Usage'
        {
            return 'Windows Azure Pack - Usage Extension - 2013'
        }
        'MgmtSvc-AdminAPI'
        {
            return 'Windows Azure Pack - Admin API - 2013'
        }
        'MgmtSvc-TenantAPI'
        {
            return 'Windows Azure Pack - Tenant API - 2013'
        }
        'MgmtSvc-TenantPublicAPI'
        {
            return 'Windows Azure Pack - Tenant Public API - 2013'
        }
        'MgmtSvc-SQLServer'
        {
            return 'Windows Azure Pack - SQL Server Extension - 2013'
        }
        'MgmtSvc-MySQL'
        {
            return 'Windows Azure Pack - MySQL Extension - 2013'
        }
        'MgmtSvc-AdminSite'
        {
            return 'Windows Azure Pack - Admin Site - 2013'
        }
        'MgmtSvc-WindowsAuthSite'
        {
            return 'Windows Azure Pack - Admin Authentication Site - 2013'
        }
        'MgmtSvc-TenantSite'
        {
            return 'Windows Azure Pack - Tenant Site - 2013'
        }
        'MgmtSvc-AuthSite'
        {
            return 'Windows Azure Pack - Tenant Authentication Site - 2013'
        }
        'MgmtSvc-ConfigSite'
        {
            return 'Windows Azure Pack - Configuration Site - 2013'
        }
    }
}

function Get-ComponentInstalled
{
    param
    (
        [String[]]
        $Products,

        [String[]]
        $ComponentNames
    )

    $ComponentInstalled = $false
    foreach($ComponentName in $ComponentNames)
    {
        if(!$ComponentInstalled)
        {
            if($Products | Where-Object {$_ -eq $ComponentName})
            {
                $ComponentInstalled = $true
            }
        }
    }

    return $ComponentInstalled
}

Export-ModuleMember -Function *-TargetResource
