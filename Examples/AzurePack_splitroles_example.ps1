[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '')]
param
()

$InstallerPassword   = ConvertTo-SecureString -String 'P@ssw0rd123!' -AsPlainText -Force
$ServerAdminPassword = ConvertTo-SecureString -String 'P@ssw0rd123!' -AsPlainText -Force
$WAPPassphrase       = ConvertTo-SecureString -String 'P@ssw0rd123!' -AsPlainText -Force

Configuration Example_WindowsAzurePack
{
    Import-DscResource -Module xSQLServer
    Import-DscResource -Module xCredSSP
    Import-DscResource -Module xAzurePack
    Import-DscResource -Module PSDesiredStateConfiguration
    Import-DscResource -Module xWebAdministration
    Import-DscResource -Module cManageCertificates

    # Set role and instance variables
    $Roles = $AllNodes.Roles | Sort-Object -Unique
    foreach($Role in $Roles)
    {
        $Servers = @($AllNodes.Where{
                $_.Roles | Where-Object -FilterScript {
                    $_ -eq $Role
                }
        }.NodeName)
        Set-Variable -Name ($Role.Replace(' ','').Replace('.','') + 's') -Value $Servers
        if($Servers.Count -eq 1)
        {
            Set-Variable -Name ($Role.Replace(' ','').Replace('.','')) -Value $Servers[0]
            if(
                $Role.Contains('Database') -or
                $Role.Contains('Datawarehouse') -or
                $Role.Contains('Reporting') -or
                $Role.Contains('Analysis') -or 
                $Role.Contains('Integration')
            )
            {
                $Instance = $AllNodes.Where{
                    $_.NodeName -eq $Servers[0]
                }.SQLServers.Where{
                    $_.Roles | Where-Object -FilterScript {
                        $_ -eq $Role
                    }
                }.InstanceName
                Set-Variable -Name ($Role.Replace(' ','').Replace('.','').Replace('Server','Instance')) -Value $Instance
            }
        }
    }

    Node $AllNodes.NodeName
    {
        # Enable CredSSP
        if(
            ($WindowsAzurePack2013AdminAPIServers | Where-Object -FilterScript {
                    $_ -eq $Node.NodeName
            }) -or
            ($WindowsAzurePack2013TenantAPIServers | Where-Object -FilterScript {
                    $_ -eq $Node.NodeName
            }) -or
            ($WindowsAzurePack2013TenantPublicAPIServers | Where-Object -FilterScript {
                    $_ -eq $Node.NodeName
            }) -or
            ($WindowsAzurePack2013SQLServerExtensionServers | Where-Object -FilterScript {
                    $_ -eq $Node.NodeName
            }) -or
            ($WindowsAzurePack2013MySQLExtensionServers | Where-Object -FilterScript {
                    $_ -eq $Node.NodeName
            }) -or
            ($WindowsAzurePack2013AdminSiteServers | Where-Object -FilterScript {
                    $_ -eq $Node.NodeName
            }) -or
            ($WindowsAzurePack2013AdminAuthenticationServers | Where-Object -FilterScript {
                    $_ -eq $Node.NodeName
            }) -or
            ($WindowsAzurePack2013TenantSiteServers | Where-Object -FilterScript {
                    $_ -eq $Node.NodeName
            }) -or
            ($WindowsAzurePack2013TenantAuthenticationSiteServers | Where-Object -FilterScript {
                    $_ -eq $Node.NodeName
            })
        )
        {            
            xCredSSP 'Server'
            {
                Ensure = 'Present'
                Role = 'Server'
            }

            xCredSSP 'Client'
            {
                Ensure = 'Present'
                Role = 'Client'
                DelegateComputers = $Node.NodeName
            }
        }

        # Install .NET Framework 3.5 on SQL nodes
        if(
            ($WindowsAzurePack2013DatabaseServer -eq $Node.NodeName) -or
            ($WindowsAzurePack2013AdminAPIServers | Where-Object -FilterScript {
                    $_ -eq $Node.NodeName
            }) -or
            ($WindowsAzurePack2013TenantAPIServers | Where-Object -FilterScript {
                    $_ -eq $Node.NodeName
            }) -or
            ($WindowsAzurePack2013TenantPublicAPIServers | Where-Object -FilterScript {
                    $_ -eq $Node.NodeName
            }) -or
            ($WindowsAzurePack2013SQLServerExtensionServers | Where-Object -FilterScript {
                    $_ -eq $Node.NodeName
            }) -or
            ($WindowsAzurePack2013MySQLExtensionServers | Where-Object -FilterScript {
                    $_ -eq $Node.NodeName
            }) -or
            ($WindowsAzurePack2013AdminSiteServers | Where-Object -FilterScript {
                    $_ -eq $Node.NodeName
            }) -or
            ($WindowsAzurePack2013AdminAuthenticationServers | Where-Object -FilterScript {
                    $_ -eq $Node.NodeName
            }) -or
            ($WindowsAzurePack2013TenantSiteServers | Where-Object -FilterScript {
                    $_ -eq $Node.NodeName
            }) -or
            ($WindowsAzurePack2013TenantAuthenticationSiteServers | Where-Object -FilterScript {
                    $_ -eq $Node.NodeName
            }) -or
            ($SQLServer2014ManagementTools | Where-Object -FilterScript {
                    $_ -eq $Node.NodeName
            })
        )
        {
            WindowsFeature 'NETFrameworkCore'
            {
                Ensure = 'Present'
                Name = 'NET-Framework-Core'
            }
        }

        # Install IIS
        if(
            ($WindowsAzurePack2013AdminAPIServers | Where-Object -FilterScript {
                    $_ -eq $Node.NodeName
            }) -or
            ($WindowsAzurePack2013TenantAPIServers | Where-Object -FilterScript {
                    $_ -eq $Node.NodeName
            }) -or
            ($WindowsAzurePack2013TenantPublicAPIServers | Where-Object -FilterScript {
                    $_ -eq $Node.NodeName
            }) -or
            ($WindowsAzurePack2013SQLServerExtensionServers | Where-Object -FilterScript {
                    $_ -eq $Node.NodeName
            }) -or
            ($WindowsAzurePack2013MySQLExtensionServers | Where-Object -FilterScript {
                    $_ -eq $Node.NodeName
            }) -or
            ($WindowsAzurePack2013AdminSiteServers | Where-Object -FilterScript {
                    $_ -eq $Node.NodeName
            }) -or
            ($WindowsAzurePack2013AdminAuthenticationServers | Where-Object -FilterScript {
                    $_ -eq $Node.NodeName
            }) -or
            ($WindowsAzurePack2013TenantSiteServers | Where-Object -FilterScript {
                    $_ -eq $Node.NodeName
            }) -or
            ($WindowsAzurePack2013TenantAuthenticationSiteServers | Where-Object -FilterScript {
                    $_ -eq $Node.NodeName
            })
        )
        {
            WindowsFeature 'Web-WebServer'
            {
                Ensure = 'Present'
                Name = 'Web-WebServer'
            }

            WindowsFeature 'Web-Default-Doc'
            {
                Ensure = 'Present'
                Name = 'Web-Default-Doc'
            }

            WindowsFeature 'Web-Static-Content'
            {
                Ensure = 'Present'
                Name = 'Web-Static-Content'
            }

            WindowsFeature 'Web-Stat-Compression'
            {
                Ensure = 'Present'
                Name = 'Web-Stat-Compression'
            }

            WindowsFeature 'Web-Filtering'
            {
                Ensure = 'Present'
                Name = 'Web-Filtering'
            }

            WindowsFeature 'Web-Dyn-Compression'
            {
                Ensure = 'Present'
                Name = 'Web-Dyn-Compression'
            }

            WindowsFeature 'Web-Windows-Auth'
            {
                Ensure = 'Present'
                Name = 'Web-Windows-Auth'
            }

            WindowsFeature 'NET-Framework-45-ASPNET'
            {
                Ensure = 'Present'
                Name = 'NET-Framework-45-ASPNET'
            }
       
            WindowsFeature 'Web-Net-Ext45'
            {
                Ensure = 'Present'
                Name = 'Web-Net-Ext45'
            }

            WindowsFeature 'Web-ISAPI-Ext'
            {
                Ensure = 'Present'
                Name = 'Web-ISAPI-Ext'
            }

            WindowsFeature 'Web-ISAPI-Filter'
            {
                Ensure = 'Present'
                Name = 'Web-ISAPI-Filter'
            }

            WindowsFeature 'Web-Asp-Net45'
            {
                Ensure = 'Present'
                Name = 'Web-Asp-Net45'
            }

            WindowsFeature 'Web-Metabase'
            {
                Ensure = 'Present'
                Name = 'Web-Metabase'
            }

            WindowsFeature 'PowerShell'
            {
                Ensure = 'Present'
                Name = 'PowerShell'
            }

            WindowsFeature 'PowerShell-V2'
            {
                Ensure = 'Present'
                Name = 'PowerShell-V2'
            }

            WindowsFeature 'WAS-Process-Model'
            {
                Ensure = 'Present'
                Name = 'WAS-Process-Model'
            }

            WindowsFeature 'WAS-NET-Environment'
            {
                Ensure = 'Present'
                Name = 'WAS-NET-Environment'
            }

            WindowsFeature 'WAS-Config-APIs'
            {
                Ensure = 'Present'
                Name = 'WAS-Config-APIs'
            }
        }
        if(
            ($WindowsAzurePack2013AdminSiteServers | Where-Object -FilterScript {
                    $_ -eq $Node.NodeName
            }) -or
            ($WindowsAzurePack2013AdminAuthenticationServers | Where-Object -FilterScript {
                    $_ -eq $Node.NodeName
            }) -or
            ($WindowsAzurePack2013TenantSiteServers | Where-Object -FilterScript {
                    $_ -eq $Node.NodeName
            }) -or
            ($WindowsAzurePack2013TenantAuthenticationSiteServers | Where-Object -FilterScript {
                    $_ -eq $Node.NodeName
            })
        )
        {
            WindowsFeature 'Web-Mgmt-Console'
            {
                Ensure = 'Present'
                Name = 'Web-Mgmt-Console'
            }
        }
        if(
            ($WindowsAzurePack2013TenantSiteServers | Where-Object -FilterScript {
                    $_ -eq $Node.NodeName
            })
        )
        {
            WindowsFeature 'Web-Basic-Auth'
            {
                Ensure = 'Present'
                Name = 'Web-Basic-Auth'
            }
        }

        # Install SQL Instances
        if(
            ($WindowsAzurePack2013DatabaseServer -eq $Node.NodeName)
        )
        {
            foreach($SQLServer in $Node.SQLServers)
            {
                $SQLInstanceName = $SQLServer.InstanceName
                $SQLServiceaccount  = $SQLServer.Serviceaccount

                $Features = ''
                if(
                    (
                        ($WindowsAzurePack2013DatabaseServer -eq $Node.NodeName) -and
                        ($WindowsAzurePack2013DatabaseInstance -eq $SQLInstanceName)
                    )
                )
                {
                    $Features += 'SQLENGINE'
                }
                $Features = $Features.Trim(',')

                if($Features -ne '')
                {
                    Group ($Node.NodeName + $SQLInstanceName)
                    {
                        Ensure = 'Present'
                        GroupName = 'MSSQL_Administrators'
                        Description = 'sysadmins in MSSQL'
                        MembersToInclude = $Node.SQLSysadmins
                        Credential = $Node.InstallerServiceAccount
                    }

                    User ($Node.NodeName + $SQLInstanceName)
                    {
                        DependsOn = ('[Group]' + $Node.NodeName + $SQLInstanceName)
                        UserName = $SQLServiceaccount.Username
                        Description = 'service account MSSQL'
                        Password = $SQLServiceaccount
                        Ensure = 'Present'
                    }
                    
                    cSqlServerSetup ($Node.NodeName + $SQLInstanceName)
                    {
                        DependsOn = '[WindowsFeature]NETFrameworkCore'
                        SourcePath = $Node.SQLSourcePath
                        SourceFolder = $Node.SQLSourceFolder
                        SetupCredential = $Node.InstallerServiceAccount
                        InstanceName = $SQLInstanceName
                        Features = $Features
                        SQLSysAdminAccounts = $Node.AdminAccount
                        SQLSvcAccount = $SQLServiceaccount
                        SecurityMode = 'SQL'
                        SAPwd = $Node.SAPassword
                        UpdateSource = '.\MU'
                        InstallSharedDir = 'C:\Program Files\Microsoft SQL Server'
                        InstallSharedWOWDir = 'C:\Program Files (x86)\Microsoft SQL Server'
                        InstanceDir = 'D:\Microsoft SQL Server'
                        InstallSQLDataDir = 'D:\Microsoft SQL Server'
                        SQLUserDBDir = 'D:\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\Data'
                        SQLUserDBLogDir = 'D:\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\Data'
                        SQLTempDBDir = 'D:\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\Data'
                        SQLTempDBLogDir = 'D:\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\Data'
                        SQLBackupDir = 'D:\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\Data'
                        ASDataDir = 'D:\Microsoft SQL Server\MSAS12.MSSQLSERVER\OLAP\Data'
                        ASLogDir = 'D:\Microsoft SQL Server\MSAS12.MSSQLSERVER\OLAP\Log'
                        ASBackupDir = 'D:\Microsoft SQL Server\MSAS12.MSSQLSERVER\OLAP\Backup'
                        ASTempDir = 'D:\Microsoft SQL Server\MSAS12.MSSQLSERVER\OLAP\Temp'
                        ASConfigDir = 'D:\Microsoft SQL Server\MSAS12.MSSQLSERVER\OLAP\Config'
                    }

                    cSqlServerFirewall ($Node.NodeName + $SQLInstanceName)
                    {
                        DependsOn = ('[cSqlServerSetup]' + $Node.NodeName + $SQLInstanceName)
                        SourcePath = $Node.SQLSourcePath
                        SourceFolder = $Node.SQLSourceFolder
                        InstanceName = $SQLInstanceName
                        Features = $Features
                    }
                    Service ($Node.NodeName + $SQLInstanceName)
                    {
                        DependsOn   = ('[cSqlServerSetup]' + $Node.NodeName + $SQLInstanceName)
                        Name        = $SQLServer.InstanceName
                        StartupType = 'Automatic'
                        State       = 'Running'
                        Credential  = $SQLServiceaccount
                    }
                }
            }
        }

        # Install ASP.NET Web Pages 2 and ASP.NET MVC 4
        if(
            ($WindowsAzurePack2013AdminAPIServers | Where-Object -FilterScript {
                    $_ -eq $Node.NodeName
            }) -or
            ($WindowsAzurePack2013TenantAPIServers | Where-Object -FilterScript {
                    $_ -eq $Node.NodeName
            }) -or
            ($WindowsAzurePack2013TenantPublicAPIServers | Where-Object -FilterScript {
                    $_ -eq $Node.NodeName
            }) -or
            ($WindowsAzurePack2013SQLServerExtensionServers | Where-Object -FilterScript {
                    $_ -eq $Node.NodeName
            }) -or
            ($WindowsAzurePack2013MySQLExtensionServers | Where-Object -FilterScript {
                    $_ -eq $Node.NodeName
            }) -or
            ($WindowsAzurePack2013AdminSiteServers | Where-Object -FilterScript {
                    $_ -eq $Node.NodeName
            }) -or
            ($WindowsAzurePack2013AdminAuthenticationServers | Where-Object -FilterScript {
                    $_ -eq $Node.NodeName
            }) -or
            ($WindowsAzurePack2013TenantSiteServers | Where-Object -FilterScript {
                    $_ -eq $Node.NodeName
            }) -or
            ($WindowsAzurePack2013TenantAuthenticationSiteServers | Where-Object -FilterScript {
                    $_ -eq $Node.NodeName
            })
        )
        {
            # Install ASP.NET Web Pages 2
            $ASPNETWebPages2 = '\Prerequisites\ASPNETWebPages2\AspNetWebPages2Setup.exe'

            Package 'ASPNETWebPages2'
            {
                Ensure = 'Present'
                Name = 'Microsoft ASP.NET Web Pages 2 Runtime'
                ProductId = ''
                Path = (Join-Path -Path $Node.WAPSourcePath -ChildPath $ASPNETWebPages2)
                Arguments = '/q'
                Credential = $Node.InstallerServiceAccount
            }
            
            # Install ASP.NET MVC 4
            $ASPNETMVC4 = '\Prerequisites\ASPNETMVC4\AspNetMVC4Setup.exe'
            Package 'ASPNETMVC4'
            {
                Ensure = 'Present'
                Name = 'Microsoft ASP.NET MVC 4 Runtime'
                ProductId = ''
                Path = (Join-Path -Path $Node.WAPSourcePath -ChildPath $ASPNETMVC4)
                Arguments = '/q'
                Credential = $Node.InstallerServiceAccount
            }
        }

        # Install MySQL Connector Net 6.5.4
        if(
            ($WindowsAzurePack2013MySQLExtensionServers | Where-Object -FilterScript {
                    $_ -eq $Node.NodeName
            })
        )
        {
            # Install MySQL Connector Net 6.5.4
            $MySQLConnectorNet654 = '\Prerequisites\MySQLConnectorNet654\mysql-connector-net-6.5.4.msi'
            Package 'MySQLConnectorNet654'
            {
                Ensure = 'Present'
                Name = 'MySQL Connector Net 6.5.4'
                ProductId = ''
                Path = (Join-Path -Path $Node.WAPSourcePath -ChildPath $MySQLConnectorNet654)
                Arguments = 'ALLUSERS=2'
                Credential = $Node.InstallerServiceAccount
            }
        }

        # Install URL Rewrite 2
        if(
            ($WindowsAzurePack2013AdminSiteServers | Where-Object -FilterScript {
                    $_ -eq $Node.NodeName
            }) -or
            ($WindowsAzurePack2013AdminAuthenticationServers | Where-Object -FilterScript {
                    $_ -eq $Node.NodeName
            }) -or
            ($WindowsAzurePack2013TenantSiteServers | Where-Object -FilterScript {
                    $_ -eq $Node.NodeName
            }) -or
            ($WindowsAzurePack2013TenantAuthenticationSiteServers | Where-Object -FilterScript {
                    $_ -eq $Node.NodeName
            })
        )
        {
            # Install URL Rewrite 2
            $URLRewrite2 = '\Prerequisites\URLRewrite2\rewrite_amd64_en-US.msi'
            Package 'URLRewrite2'
            {
                Ensure = 'Present'
                Name = 'IIS URL Rewrite Module 2'
                ProductId = ''
                Path = (Join-Path -Path $Node.WAPSourcePath -ChildPath $URLRewrite2)
                Arguments = 'ALLUSERS=2'
                Credential = $Node.InstallerServiceAccount
            }
        }

        # Install and initialize Azure Pack Admin API
        if(
            ($WindowsAzurePack2013AdminAPIServers | Where-Object -FilterScript {
                    $_ -eq $Node.NodeName
            })
        )
        {
            cAzurePackSetup 'AdminAPIInstall'
            {
                Role = 'Admin API'
                Action = 'Install'
                SourcePath = $Node.WAPSourcePath
                SourceFolder = 'Installer'
                SetupCredential = $Node.InstallerServiceAccount
                Passphrase = $Node.WAPackPassphrase
            }

            $DependsOn = @()

            if(
                ($WindowsAzurePack2013AdminAPIServers[0] -eq $Node.NodeName)
            )
            {
                # Wait for Azure Pack Database Server
                if ($WindowsAzurePack2013AdminAPIServers[0] -eq $WindowsAzurePack2013DatabaseServer)
                {
                    $DependsOn = @(('[cSqlServerFirewall]' + $WindowsAzurePack2013DatabaseServer + $WindowsAzurePack2013DatabaseInstance))
                }
                else
                {
                    WaitForAll 'WAPDB'
                    {
                        NodeName = $WindowsAzurePack2013DatabaseServer
                        ResourceName = ('[cSqlServerFirewall]' + $WindowsAzurePack2013DatabaseServer + $WindowsAzurePack2013DatabaseInstance)
                        PsDscRunAsCredential = $Node.InstallerServiceAccount
                        RetryCount = 720
                        RetryIntervalSec = 20
                    }
                    $DependsOn = @('[WaitForAll]WAPDB')
                }

                $DependsOn += @(
                    '[xCredSSP]Client', 
                    '[xCredSSP]Server', 
                    '[cAzurePackSetup]AdminAPIInstall'
                )

                cAzurePackSetup 'AdminAPIInitialize'
                {
                    DependsOn = $DependsOn
                    Role = 'Admin API'
                    Action = 'Initialize'
                    dbUser = $Node.SAPassword
                    SourcePath = $Node.WAPSourcePath
                    SourceFolder = 'Installer'
                    SetupCredential = $Node.InstallerServiceAccount
                    Passphrase = $Node.WAPackPassphrase
                    SQLServer = $WindowsAzurePack2013DatabaseServer
                    SQLInstance = $WindowsAzurePack2013DatabaseInstance
                }

                if($Node.AzurePackAdminAPIFQDN)
                {
                    if ($Node.AzurePackAdminAPIPort)
                    {
                        $AzurePackAdminAPIPort = $Node.AzurePackAdminAPIPort
                    }
                    else
                    {
                        $AzurePackAdminAPIPort = 30004
                    }

                    cAzurePackDatabaseSetting 'AntaresGeoMasterUri'
                    {
                        DependsOn = '[cAzurePackSetup]AdminAPIInitialize'
                        Namespace = 'AdminSite'
                        Name = 'Microsoft.Azure.Portal.Configuration.AppManagementConfiguration.AntaresGeoMasterUri'
                        Value = ('https://' + $Node.AzurePackAdminAPIFQDN + ':' + $AzurePackAdminAPIPort + '/services/webspaces/')
                        AzurePackAdminCredential = $Node.InstallerServiceAccount
                        SQLServer = $WindowsAzurePack2013DatabaseServer
                        SQLInstance = $WindowsAzurePack2013DatabaseInstance
                        dbUser = $Node.SAPassword
                    }

                    cAzurePackDatabaseSetting 'RdfeAdminManagementServiceUri'
                    {
                        DependsOn = '[cAzurePackSetup]AdminAPIInitialize'
                        Namespace = 'AdminSite'
                        Name = 'Microsoft.Azure.Portal.Configuration.AppManagementConfiguration.RdfeAdminManagementServiceUri'
                        Value = ('https://' + $Node.AzurePackAdminAPIFQDN + ':' + $AzurePackAdminAPIPort + '/')
                        AzurePackAdminCredential = $Node.InstallerServiceAccount
                        SQLServer = $WindowsAzurePack2013DatabaseServer
                        SQLInstance = $WindowsAzurePack2013DatabaseInstance
                        dbUser = $Node.SAPassword
                    }

                    cAzurePackDatabaseSetting 'RdfeAdminUri'
                    {
                        DependsOn = '[cAzurePackSetup]AdminAPIInitialize'
                        Namespace = 'AdminSite'
                        Name = 'Microsoft.Azure.Portal.Configuration.OnPremPortalConfiguration.RdfeAdminUri'
                        Value = ('https://' + $Node.AzurePackAdminAPIFQDN + ':' + $AzurePackAdminAPIPort + '/')
                        AzurePackAdminCredential = $Node.InstallerServiceAccount
                        SQLServer = $WindowsAzurePack2013DatabaseServer
                        SQLInstance = $WindowsAzurePack2013DatabaseInstance
                        dbUser = $Node.SAPassword
                    }

                    cAzurePackDatabaseSetting 'RdfeProvisioningUri'
                    {
                        DependsOn = '[cAzurePackSetup]AdminAPIInitialize'
                        Namespace = 'AdminSite'
                        Name = 'Microsoft.Azure.Portal.Configuration.OnPremPortalConfiguration.RdfeProvisioningUri'
                        Value = ('https://' + $Node.AzurePackAdminAPIFQDN + ':' + $AzurePackAdminAPIPort + '/')
                        AzurePackAdminCredential = $Node.InstallerServiceAccount
                        SQLServer = $WindowsAzurePack2013DatabaseServer
                        SQLInstance = $WindowsAzurePack2013DatabaseInstance
                        dbUser = $Node.SAPassword
                    }
                }
            }
            else
            {
                WaitForAll 'AdminAPIInitialize'
                {
                    NodeName = $WindowsAzurePack2013AdminAPIServers[0]
                    ResourceName = '[cAzurePackSetup]AdminAPIInitialize'
                    PsDscRunAsCredential = $Node.InstallerServiceAccount
                    RetryCount = 720
                    RetryIntervalSec = 20
                }

                cAzurePackSetup 'AdminAPIInitialize'
                {
                    DependsOn = @(
                        '[xCredSSP]Client', 
                        '[xCredSSP]Server', 
                        '[cAzurePackSetup]AdminAPIInstall', 
                        '[WaitForAll]AdminAPIInitialize'
                    )
                    Role = 'Admin API'
                    Action = 'Initialize'
                    dbUser = $Node.SAPassword
                    SourcePath = $Node.WAPSourcePath
                    SourceFolder = 'Installer'
                    SetupCredential = $Node.InstallerServiceAccount
                    Passphrase = $Node.WAPackPassphrase
                    SQLServer = $WindowsAzurePack2013DatabaseServer
                    SQLInstance = $WindowsAzurePack2013DatabaseInstance
                }
            }

            if($Node.AzurePackAdministratorsGroup)
            {
                cAzurePackAdmin 'WAPAdministrators'
                {
                    DependsOn = '[cAzurePackSetup]AdminAPIInitialize'
                    Principal = $Node.AzurePackAdministratorsGroup
                    AzurePackAdminCredential = $Node.InstallerServiceAccount
                    SQLServer = $WindowsAzurePack2013DatabaseServer
                    SQLInstance = $WindowsAzurePack2013DatabaseInstance
                    dbUser = $Node.SAPassword
                }
            }

        }

        # Install and initialize Azure Pack Tenant API
        if(
            ($WindowsAzurePack2013TenantAPIServers | Where-Object -FilterScript {
                    $_ -eq $Node.NodeName
            })
        )
        {
            cAzurePackSetup 'TenantAPIInstall'
            {
                Role = 'Tenant API'
                Action = 'Install'
                SourcePath = $Node.WAPSourcePath
                SourceFolder = 'Installer'
                SetupCredential = $Node.InstallerServiceAccount
                Passphrase = $Node.WAPackPassphrase
            }

            $DependsOn = @()

            if(
                ($WindowsAzurePack2013TenantAPIServers[0] -eq $Node.NodeName)
            )
            {
                # Wait for Admin API
                if ($WindowsAzurePack2013TenantAPIServers[0] -eq $WindowsAzurePack2013AdminAPIServers[0])
                {
                    $DependsOn = @('[cAzurePackSetup]AdminAPIInitialize')
                }
                else
                {
                    WaitForAll 'AdminAPI'
                    {
                        NodeName = $WindowsAzurePack2013AdminAPIServers[0]
                        ResourceName = ('[cAzurePackSetup]AdminAPIInitialize')
                        PsDscRunAsCredential = $Node.InstallerServiceAccount
                        RetryCount = 720
                        RetryIntervalSec = 20
                    }
                    $DependsOn = @('[WaitForAll]AdminAPI')
                }

                $DependsOn += @(
                    '[xCredSSP]Client', 
                    '[xCredSSP]Server', 
                    '[cAzurePackSetup]TenantAPIInstall'
                )

                cAzurePackSetup 'TenantAPIInitialize'
                {
                    DependsOn = $DependsOn
                    Role = 'Tenant API'
                    Action = 'Initialize'
                    dbUser = $Node.SAPassword
                    SourcePath = $Node.WAPSourcePath
                    SourceFolder = 'Installer'
                    SetupCredential = $Node.InstallerServiceAccount
                    Passphrase = $Node.WAPackPassphrase
                    SQLServer = $WindowsAzurePack2013DatabaseServer
                    SQLInstance = $WindowsAzurePack2013DatabaseInstance
                }

                if($Node.AzurePackTenantAPIFQDN)
                {
                    if ($Node.AzurePackTenantAPIPort)
                    {
                        $AzurePackTenantAPIPort = $Node.AzurePackTenantAPIPort
                    }
                    else
                    {
                        $AzurePackTenantAPIPort = 30005
                    }

                    cAzurePackDatabaseSetting 'AdminSite-RdfeUnifiedManagementServiceUri'
                    {
                        DependsOn = '[cAzurePackSetup]TenantAPIInitialize'
                        Namespace = 'AdminSite'
                        Name = 'Microsoft.Azure.Portal.Configuration.AppManagementConfiguration.RdfeUnifiedManagementServiceUri'
                        Value = ('https://' + $Node.AzurePackTenantAPIFQDN + ':' + $AzurePackTenantAPIPort + '/')
                        AzurePackAdminCredential = $Node.InstallerServiceAccount
                        SQLServer = $WindowsAzurePack2013DatabaseServer
                        SQLInstance = $WindowsAzurePack2013DatabaseInstance
                        dbUser = $Node.SAPassword
                    }

                    cAzurePackDatabaseSetting 'TenantSite-RdfeUnifiedManagementServiceUri'
                    {
                        DependsOn = '[cAzurePackSetup]TenantAPIInitialize'
                        Namespace = 'TenantSite'
                        Name = 'Microsoft.Azure.Portal.Configuration.AppManagementConfiguration.RdfeUnifiedManagementServiceUri'
                        Value = ('https://' + $Node.AzurePackTenantAPIFQDN + ':' + $AzurePackTenantAPIPort + '/')
                        AzurePackAdminCredential = $Node.InstallerServiceAccount
                        SQLServer = $WindowsAzurePack2013DatabaseServer
                        SQLInstance = $WindowsAzurePack2013DatabaseInstance
                        dbUser = $Node.SAPassword
                    }
                }
            }
            else
            {
                WaitForAll 'TenantAPIInitialize'
                {
                    NodeName = $WindowsAzurePack2013TenantAPIServers[0]
                    ResourceName = '[cAzurePackSetup]TenantAPIInitialize'
                    PsDscRunAsCredential = $Node.InstallerServiceAccount
                    RetryCount = 720
                    RetryIntervalSec = 20
                }

                cAzurePackSetup 'TenantAPIInitialize'
                {
                    DependsOn = @(
                        '[xCredSSP]Client', 
                        '[xCredSSP]Server', 
                        '[cAzurePackSetup]TenantAPIInstall', 
                        '[WaitForAll]TenantAPIInitialize'
                    )
                    Role = 'Tenant API'
                    Action = 'Initialize'
                    dbUser = $Node.SAPassword
                    SourcePath = $Node.WAPSourcePath
                    SourceFolder = 'Installer'
                    SetupCredential = $Node.InstallerServiceAccount
                    Passphrase = $Node.WAPackPassphrase
                    SQLServer = $WindowsAzurePack2013DatabaseServer
                    SQLInstance = $WindowsAzurePack2013DatabaseInstance
                }
            }
        }

        # Install and initialize Azure Pack Tenant Public API
        if(
            ($WindowsAzurePack2013TenantPublicAPIServers | Where-Object -FilterScript {
                    $_ -eq $Node.NodeName
            })
        )
        {
            cAzurePackSetup 'TenantPublicAPIInstall'
            {
                Role = 'Tenant Public API'
                Action = 'Install'
                SourcePath = $Node.WAPSourcePath
                SourceFolder = 'Installer'
                SetupCredential = $Node.InstallerServiceAccount
                Passphrase = $Node.WAPackPassphrase
            }

            $DependsOn = @()

            if(
                ($WindowsAzurePack2013TenantPublicAPIServers[0] -eq $Node.NodeName)
            )
            {
                # Wait for Tenant API
                if ($WindowsAzurePack2013TenantPublicAPIServers[0] -eq $WindowsAzurePack2013TenantAPIServers[0])
                {
                    $DependsOn = @('[cAzurePackSetup]TenantAPIInitialize')
                }
                else
                {
                    WaitForAll 'TenantAPI'
                    {
                        NodeName = $WindowsAzurePack2013TenantAPIServers[0]
                        ResourceName = ('[cAzurePackSetup]TenantAPIInitialize')
                        PsDscRunAsCredential = $Node.InstallerServiceAccount
                        RetryCount = 720
                        RetryIntervalSec = 20
                    }
                    $DependsOn = @('[WaitForAll]TenantAPI')
                }

                $DependsOn += @(
                    '[xCredSSP]Client', 
                    '[xCredSSP]Server', 
                    '[cAzurePackSetup]TenantPublicAPIInstall'
                )

                cAzurePackSetup 'TenantPublicAPIInitialize'
                {
                    DependsOn = $DependsOn
                    Role = 'Tenant Public API'
                    Action = 'Initialize'
                    dbUser = $Node.SAPassword
                    SourcePath = $Node.WAPSourcePath
                    SourceFolder = 'Installer'
                    SetupCredential = $Node.InstallerServiceAccount
                    Passphrase = $Node.WAPackPassphrase
                    SQLServer = $WindowsAzurePack2013DatabaseServer
                    SQLInstance = $WindowsAzurePack2013DatabaseInstance
                }

                if($Node.AzurePackTenantPublicAPIFQDN)
                {
                    if ($Node.AzurePackTenantPublicAPIPort)
                    {
                        $AzurePackTenantPublicAPIPort = $Node.AzurePackTenantPublicAPIPort
                    }
                    else
                    {
                        $AzurePackTenantPublicAPIPort = 30006
                    }

                    cAzurePackDatabaseSetting 'PublicRdfeProvisioningUri'
                    {
                        DependsOn = '[cAzurePackSetup]TenantPublicAPIInitialize'
                        Namespace = 'TenantSite'
                        Name = 'Microsoft.WindowsAzure.Server.Configuration.TenantPortalConfiguration.PublicRdfeProvisioningUri'
                        Value = ('https://' + $Node.AzurePackTenantPublicAPIFQDN + ':' + $AzurePackTenantPublicAPIPort + '/')
                        AzurePackAdminCredential = $Node.InstallerServiceAccount
                        SQLServer = $WindowsAzurePack2013DatabaseServer
                        SQLInstance = $WindowsAzurePack2013DatabaseInstance
                        dbUser = $Node.SAPassword
                    }
                }
            }
            else
            {
                WaitForAll 'TenantPublicAPIInitialize'
                {
                    NodeName = $WindowsAzurePack2013TenantPublicAPIServers[0]
                    ResourceName = '[cAzurePackSetup]TenantPublicAPIInitialize'
                    PsDscRunAsCredential = $Node.InstallerServiceAccount
                    RetryCount = 720
                    RetryIntervalSec = 20
                }

                cAzurePackSetup 'TenantPublicAPIInitialize'
                {
                    DependsOn = @(
                        '[xCredSSP]Client', 
                        '[xCredSSP]Server', 
                        '[cAzurePackSetup]TenantPublicAPIInstall', 
                        '[WaitForAll]TenantPublicAPIInitialize'
                    )
                    Role = 'Tenant Public API'
                    Action = 'Initialize'
                    dbUser = $Node.SAPassword
                    SourcePath = $Node.WAPSourcePath
                    SourceFolder = 'Installer'
                    SetupCredential = $Node.InstallerServiceAccount
                    Passphrase = $Node.WAPackPassphrase
                    SQLServer = $WindowsAzurePack2013DatabaseServer
                    SQLInstance = $WindowsAzurePack2013DatabaseInstance
                }
            }
        }

        # Install and initialize Azure Pack SQL Server Extension
        if(
            ($WindowsAzurePack2013SQLServerExtensionServers | Where-Object -FilterScript {
                    $_ -eq $Node.NodeName
            })
        )
        {
            cAzurePackSetup 'SQLServerExtensionInstall'
            {
                Role = 'SQL Server Extension'
                Action = 'Install'
                SourcePath = $Node.WAPSourcePath
                SourceFolder = 'Installer'
                SetupCredential = $Node.InstallerServiceAccount
                Passphrase = $Node.WAPackPassphrase
            }

            $DependsOn = @()

            if(
                ($WindowsAzurePack2013SQLServerExtensionServers[0] -eq $Node.NodeName)
            )
            {
                # Wait for Admin API
                if ($WindowsAzurePack2013SQLServerExtensionServers[0] -eq $WindowsAzurePack2013AdminAPIServers[0])
                {
                    $DependsOn = @('[cAzurePackSetup]AdminAPIInitialize')
                }
                else
                {
                    WaitForAll 'AdminAPI'
                    {
                        NodeName = $WindowsAzurePack2013AdminAPIServers[0]
                        ResourceName = ('[cAzurePackSetup]AdminAPIInitialize')
                        PsDscRunAsCredential = $Node.InstallerServiceAccount
                        RetryCount = 720
                        RetryIntervalSec = 20
                    }
                    $DependsOn = @('[WaitForAll]AdminAPI')
                }

                $DependsOn += @(
                    '[xCredSSP]Client', 
                    '[xCredSSP]Server', 
                    '[cAzurePackSetup]SQLServerExtensionInstall'
                )

                cAzurePackSetup 'SQLServerExtensionInitialize'
                {
                    DependsOn = $DependsOn
                    Role = 'SQL Server Extension'
                    Action = 'Initialize'
                    dbUser = $Node.SAPassword
                    SourcePath = $Node.WAPSourcePath
                    SourceFolder = 'Installer'
                    SetupCredential = $Node.InstallerServiceAccount
                    Passphrase = $Node.WAPackPassphrase
                    SQLServer = $WindowsAzurePack2013DatabaseServer
                    SQLInstance = $WindowsAzurePack2013DatabaseInstance
                }
            }
            else
            {
                WaitForAll 'SQLServerExtensionInitialize'
                {
                    NodeName = $WindowsAzurePack2013SQLServerExtensionServers[0]
                    ResourceName = '[cAzurePackSetup]SQLServerExtensionInitialize'
                    PsDscRunAsCredential = $Node.InstallerServiceAccount
                    RetryCount = 720
                    RetryIntervalSec = 20
                }

                cAzurePackSetup 'SQLServerExtensionInitialize'
                {
                    DependsOn = @(
                        '[xCredSSP]Client', 
                        '[xCredSSP]Server', 
                        '[cAzurePackSetup]SQLServerExtensionInstall', 
                        '[WaitForAll]SQLServerExtensionInitialize'
                    )
                    Role = 'SQL Server Extension'
                    Action = 'Initialize'
                    dbUser = $Node.SAPassword
                    SourcePath = $Node.WAPSourcePath
                    SourceFolder = 'Installer'
                    SetupCredential = $Node.InstallerServiceAccount
                    Passphrase = $Node.WAPackPassphrase
                    SQLServer = $WindowsAzurePack2013DatabaseServer
                    SQLInstance = $WindowsAzurePack2013DatabaseInstance
                }
            }
        }

        # Install and initialize Azure Pack MySQL Extension
        if(
            ($WindowsAzurePack2013MySQLExtensionServers | Where-Object -FilterScript {
                    $_ -eq $Node.NodeName
            })
        )
        {
            cAzurePackSetup 'MySQLExtensionInstall'
            {
                Role = 'MySQL Extension'
                Action = 'Install'
                SourcePath = $Node.WAPSourcePath
                SourceFolder = 'Installer'
                SetupCredential = $Node.InstallerServiceAccount
                Passphrase = $Node.WAPackPassphrase
            }

            $DependsOn = @()

            if(
                ($WindowsAzurePack2013MySQLExtensionServers[0] -eq $Node.NodeName)
            )
            {
                # Wait for Admin API
                if ($WindowsAzurePack2013MySQLExtensionServers[0] -eq $WindowsAzurePack2013AdminAPIServers[0])
                {
                    $DependsOn = @('[cAzurePackSetup]AdminAPIInitialize')
                }
                else
                {
                    WaitForAll 'AdminAPI'
                    {
                        NodeName = $WindowsAzurePack2013AdminAPIServers[0]
                        ResourceName = ('[cAzurePackSetup]AdminAPIInitialize')
                        PsDscRunAsCredential = $Node.InstallerServiceAccount
                        RetryCount = 720
                        RetryIntervalSec = 20
                    }
                    $DependsOn = @('[WaitForAll]AdminAPI')
                }

                $DependsOn += @(
                    '[xCredSSP]Client', 
                    '[xCredSSP]Server', 
                    '[cAzurePackSetup]MySQLExtensionInstall'
                )

                cAzurePackSetup 'MySQLExtensionInitialize'
                {
                    DependsOn = $DependsOn
                    Role = 'MySQL Extension'
                    Action = 'Initialize'
                    dbUser = $Node.SAPassword
                    SourcePath = $Node.WAPSourcePath
                    SourceFolder = 'Installer'
                    SetupCredential = $Node.InstallerServiceAccount
                    Passphrase = $Node.WAPackPassphrase
                    SQLServer = $WindowsAzurePack2013DatabaseServer
                    SQLInstance = $WindowsAzurePack2013DatabaseInstance
                }
            }
            else
            {
                WaitForAll 'MySQLExtensionInitialize'
                {
                    NodeName = $WindowsAzurePack2013MySQLExtensionServers[0]
                    ResourceName = '[cAzurePackSetup]MySQLExtensionInitialize'
                    PsDscRunAsCredential = $Node.InstallerServiceAccount
                    RetryCount = 720
                    RetryIntervalSec = 20
                }

                cAzurePackSetup 'MySQLExtensionInitialize'
                {
                    DependsOn = @(
                        '[xCredSSP]Client', 
                        '[xCredSSP]Server', 
                        '[cAzurePackSetup]MySQLExtensionInstall', 
                        '[WaitForAll]MySQLExtensionInitialize'
                    )
                    Role = 'MySQL Extension'
                    Action = 'Initialize'
                    dbUser = $Node.SAPassword
                    SourcePath = $Node.WAPSourcePath
                    SourceFolder = 'Installer'
                    SetupCredential = $Node.InstallerServiceAccount
                    Passphrase = $Node.WAPackPassphrase
                    SQLServer = $WindowsAzurePack2013DatabaseServer
                    SQLInstance = $WindowsAzurePack2013DatabaseInstance
                }
            }
        }

        # Install and initialize Azure Pack Admin Site
        if(
            ($WindowsAzurePack2013AdminSiteServers | Where-Object -FilterScript {
                    $_ -eq $Node.NodeName
            })
        )
        {
            cAzurePackSetup 'AdminSiteInstall'
            {
                Role = 'Admin Site'
                Action = 'Install'
                SourcePath = $Node.WAPSourcePath
                SourceFolder = 'Installer'
                SetupCredential = $Node.InstallerServiceAccount
                Passphrase = $Node.WAPackPassphrase
            }

            $DependsOn = @()

            if(
                ($WindowsAzurePack2013AdminSiteServers[0] -eq $Node.NodeName)
            )
            {
                # Wait for Admin API
                if ($WindowsAzurePack2013AdminSiteServers[0] -eq $WindowsAzurePack2013AdminAPIServers[0])
                {
                    $DependsOn = @('[cAzurePackSetup]AdminAPIInitialize')
                }
                else
                {
                    WaitForAll 'AdminAPI'
                    {
                        NodeName = $WindowsAzurePack2013AdminAPIServers[0]
                        ResourceName = ('[cAzurePackSetup]AdminAPIInitialize')
                        PsDscRunAsCredential = $Node.InstallerServiceAccount
                        RetryCount = 720
                        RetryIntervalSec = 20
                    }
                    $DependsOn = @('[WaitForAll]AdminAPI')
                }

                $DependsOn += @(
                    '[xCredSSP]Client', 
                    '[xCredSSP]Server', 
                    '[cAzurePackSetup]AdminSiteInstall'
                )

                cAzurePackSetup 'AdminSiteInitialize'
                {
                    DependsOn = $DependsOn
                    Role = 'Admin Site'
                    Action = 'Initialize'
                    dbUser = $Node.SAPassword
                    SourcePath = $Node.WAPSourcePath
                    SourceFolder = 'Installer'
                    SetupCredential = $Node.InstallerServiceAccount
                    Passphrase = $Node.WAPackPassphrase
                    SQLServer = $WindowsAzurePack2013DatabaseServer
                    SQLInstance = $WindowsAzurePack2013DatabaseInstance
                }

                if($Node.AzurePackAdminSiteFQDN)
                {
                    cManageCertificates 'AdminSite'
                    {
                        DependsOn = '[cAzurePackSetup]AdminSiteInitialize'
                        Thumbprint = $Node.WAPCertificateThumbprint
                        Location = $Node.WAPCertificatelocation
                        Ensure = 'Present'
                        Password = $Node.WAPCertificatepassword
                        Store = 'My'
                        StoreType = 'LocalMachine'
                        Reboot = $false
                        PsDscRunAsCredential = $Node.InstallerServiceAccount
                    }                    
                    
                    cWebsite 'AdminSite'
                    {
                        DependsOn = '[cAzurePackSetup]AdminSiteInitialize'
                        Name = 'MgmtSvc-AdminSite'
                        Ensure = 'Present'
                        State = 'Started'
                        PhysicalPath = 'C:\inetpub\MgmtSvc-AdminSite'
                        BindingInfo = cWebBindingInformation
                                      {
                                      Protocol = 'HTTPS'
                                      Port = $Node.AzurePackAdminSitePort
                                      HostName = $Node.AzurePackAdminSiteFQDN
                                      CertificateThumbprint = $Node.WAPCertificateThumbprint
                                      CertificateStoreName = 'My'
                                      }
                    }

                    cAzurePackFQDN 'AdminSite'
                    {
                        DependsOn = '[cAzurePackSetup]AdminSiteInitialize'
                        Namespace = 'AdminSite'
                        FullyQualifiedDomainName = $Node.AzurePackAdminSiteFQDN
                        Port = $Node.AzurePackAdminSitePort
                        AzurePackAdminCredential = $Node.InstallerServiceAccount
                        SQLServer = $WindowsAzurePack2013DatabaseServer
                        SQLInstance = $WindowsAzurePack2013DatabaseInstance
                        dbUser = $Node.SAPassword
                    }

                    cAzurePackIdentityProvider 'AdminSite'
                    {
                        DependsOn = '[cAzurePackSetup]AdminSiteInitialize'
                        Target = 'Windows'
                        FullyQualifiedDomainName = $Node.AzurePackAdminSiteFQDN
                        Port = $Node.AzurePackAdminSitePort
                        AzurePackAdminCredential = $Node.InstallerServiceAccount
                        SQLServer = $WindowsAzurePack2013DatabaseServer
                        SQLInstance = $WindowsAzurePack2013DatabaseInstance
                        dbUser = $Node.SAPassword
                    }
                }
            }
            else
            {
                WaitForAll 'AdminSiteInitialize'
                {
                    NodeName = $WindowsAzurePack2013AdminSiteServers[0]
                    ResourceName = '[cAzurePackSetup]AdminSiteInitialize'
                    PsDscRunAsCredential = $Node.InstallerServiceAccount
                    RetryCount = 720
                    RetryIntervalSec = 20
                }

                cAzurePackSetup 'AdminSiteInitialize'
                {
                    DependsOn = @(
                        '[xCredSSP]Client', 
                        '[xCredSSP]Server', 
                        '[cAzurePackSetup]AdminSiteInstall', 
                        '[WaitForAll]AdminSiteInitialize'
                    )
                    Role = 'Admin Site'
                    Action = 'Initialize'
                    dbUser = $Node.SAPassword
                    SourcePath = $Node.WAPSourcePath
                    SourceFolder = 'Installer'
                    SetupCredential = $Node.InstallerServiceAccount
                    Passphrase = $Node.WAPackPassphrase
                    SQLServer = $WindowsAzurePack2013DatabaseServer
                    SQLInstance = $WindowsAzurePack2013DatabaseInstance
                }
            }
        }

        # Install and initialize Azure Pack Admin Authentication Site
        if(
            ($WindowsAzurePack2013AdminAuthenticationSiteServers | Where-Object -FilterScript {
                    $_ -eq $Node.NodeName
            })
        )
        {
            cAzurePackSetup 'AdminAuthenticationSiteInstall'
            {
                Role = 'Admin Authentication Site'
                Action = 'Install'
                SourcePath = $Node.WAPSourcePath
                SourceFolder = 'Installer'
                SetupCredential = $Node.InstallerServiceAccount
                Passphrase = $Node.WAPackPassphrase
            }

            $DependsOn = @()

            if(
                ($WindowsAzurePack2013AdminAuthenticationSiteServers[0] -eq $Node.NodeName)
            )
            {
                # Wait for Admin API
                if ($WindowsAzurePack2013AdminAuthenticationSiteServers[0] -eq $WindowsAzurePack2013AdminAPIServers[0])
                {
                    $DependsOn = @('[cAzurePackSetup]AdminAPIInitialize')
                }
                else
                {
                    if ($WindowsAzurePack2013AdminAuthenticationSiteServers[0] -eq $WindowsAzurePack2013AdminSiteServers[0])
                    {
                        $DependsOn = @('[cAzurePackSetup]AdminSiteInitialize')
                    }
                    else
                    {
                        WaitForAll 'AdminAPI'
                        {
                            NodeName = $WindowsAzurePack2013AdminAPIServers[0]
                            ResourceName = ('[cAzurePackSetup]AdminAPIInitialize')
                            PsDscRunAsCredential = $Node.InstallerServiceAccount
                            RetryCount = 720
                            RetryIntervalSec = 20
                        }
                        $DependsOn = @('[WaitForAll]AdminAPI')
                    }
                    

                }

                $DependsOn += @(
                    '[xCredSSP]Client', 
                    '[xCredSSP]Server', 
                    '[cAzurePackSetup]AdminAuthenticationSiteInstall'
                )

                cAzurePackSetup 'AdminAuthenticationSiteInitialize'
                {
                    DependsOn = $DependsOn
                    Role = 'Admin Authentication Site'
                    Action = 'Initialize'
                    dbUser = $Node.SAPassword
                    SourcePath = $Node.WAPSourcePath
                    SourceFolder = 'Installer'
                    SetupCredential = $Node.InstallerServiceAccount
                    Passphrase = $Node.WAPackPassphrase
                    SQLServer = $WindowsAzurePack2013DatabaseServer
                    SQLInstance = $WindowsAzurePack2013DatabaseInstance
                    PsDscRunAsCredential = $Node.InstallerServiceAccount
                    
                }

                if($Node.AzurePackWindowsAuthSiteFQDN)
                {
                    if ($WindowsAzurePack2013AdminSiteServers[0] -ne $WindowsAzurePack2013AdminAuthenticationSiteServers[0])
                    {
                        cManageCertificates 'AdminAuthenticationSite'
                        {
                            DependsOn = '[cAzurePackSetup]AdminAuthenticationSiteInitialize'
                            Thumbprint = $Node.WAPCertificateThumbprint
                            Location = $Node.WAPCertificatelocation
                            Ensure = 'Present'
                            Password = $Node.WAPCertificatepassword
                            Store = 'My'
                            StoreType = 'LocalMachine'
                            Reboot = $false
                            PsDscRunAsCredential = $Node.InstallerServiceAccount
                        }                    
                    }                  
                    
                    cWebsite 'AdminAuthenticationSite'
                    {
                        DependsOn = '[cAzurePackSetup]AdminAuthenticationSiteInitialize'
                        Name = 'MgmtSvc-WindowsAuthSite'
                        Ensure = 'Present'
                        State = 'Started'
                        PhysicalPath = 'C:\inetpub\MgmtSvc-WindowsAuthSite'
                        BindingInfo = cWebBindingInformation
                                      {
                                      Protocol = 'HTTPS'
                                      Port = $Node.AzurePackWindowsAuthSitePort
                                      HostName = $Node.AzurePackWindowsAuthSiteFQDN
                                      CertificateThumbprint = $Node.WAPCertificateThumbprint
                                      CertificateStoreName = 'My'
                                      }
                    }

                    cAzurePackFQDN 'AdminAuthenticationSite'
                    {
                        DependsOn = '[cAzurePackSetup]AdminAuthenticationSiteInitialize'
                        Namespace = 'WindowsAuthSite'
                        Port = $Node.AzurePackWindowsAuthSitePort
                        FullyQualifiedDomainName = $Node.AzurePackWindowsAuthSiteFQDN
                        AzurePackAdminCredential = $Node.InstallerServiceAccount
                        SQLServer = $WindowsAzurePack2013DatabaseServer
                        SQLInstance = $WindowsAzurePack2013DatabaseInstance
                        dbUser = $Node.SAPassword
                    }

                    cAzurePackRelyingParty 'AdminAuthenticationSite'
                    {
                        DependsOn = '[cAzurePackSetup]AdminAuthenticationSiteInitialize'
                        Target = 'Admin'
                        FullyQualifiedDomainName = $Node.AzurePackWindowsAuthSiteFQDN
                        AzurePackAdminCredential = $Node.InstallerServiceAccount
                        SQLServer = $WindowsAzurePack2013DatabaseServer
                        SQLInstance = $WindowsAzurePack2013DatabaseInstance
                        dbUser = $Node.SAPassword
                    }
                }
            }
            else
            {
                WaitForAll 'AdminAuthenticationSiteInitialize'
                {
                    NodeName = $WindowsAzurePack2013AdminAuthenticationSiteServers[0]
                    ResourceName = '[cAzurePackSetup]AdminAuthenticationSiteInitialize'
                    PsDscRunAsCredential = $Node.InstallerServiceAccount
                    RetryCount = 720
                    RetryIntervalSec = 20
                }

                cAzurePackSetup 'AdminAuthenticationSiteInitialize'
                {
                    DependsOn = @(
                        '[xCredSSP]Client', 
                        '[xCredSSP]Server', 
                        '[cAzurePackSetup]AdminAuthenticationSiteInstall', 
                        '[WaitForAll]AdminAuthenticationSiteInitialize'
                    )
                    Role = 'Admin Authentication Site'
                    Action = 'Initialize'
                    dbUser = $Node.SAPassword
                    SourcePath = $Node.WAPSourcePath
                    SourceFolder = 'Installer'
                    SetupCredential = $Node.InstallerServiceAccount
                    Passphrase = $Node.WAPackPassphrase
                    SQLServer = $WindowsAzurePack2013DatabaseServer
                    SQLInstance = $WindowsAzurePack2013DatabaseInstance
                    PsDscRunAsCredential = $Node.InstallerServiceAccount
                }
            }
        }

        # Install and initialize Azure Pack Tenant Site
        if(
            ($WindowsAzurePack2013TenantSiteServers | Where-Object -FilterScript {
                    $_ -eq $Node.NodeName
            })
        )
        {
            cAzurePackSetup 'TenantSiteInstall'
            {
                Role = 'Tenant Site'
                Action = 'Install'
                SourcePath = $Node.WAPSourcePath
                SourceFolder = 'Installer'
                SetupCredential = $Node.InstallerServiceAccount
                Passphrase = $Node.WAPackPassphrase
            }

            $DependsOn = @()

            if(
                ($WindowsAzurePack2013TenantSiteServers[0] -eq $Node.NodeName)
            )
            {
                # Wait for Tenant Public API
                if ($WindowsAzurePack2013TenantSiteServers[0] -eq $WindowsAzurePack2013TenantPublicAPIServers[0])
                {
                    $DependsOn = @('[cAzurePackSetup]TenantPublicAPIInitialize')
                }
                else
                {
                    WaitForAll 'AdminAPI'
                    {
                        NodeName = $WindowsAzurePack2013TenantPublicAPIServers[0]
                        ResourceName = ('[cAzurePackSetup]TenantPublicAPIInitialize')
                        PsDscRunAsCredential = $Node.InstallerServiceAccount
                        RetryCount = 720
                        RetryIntervalSec = 20
                    }
                    $DependsOn = @('[WaitForAll]AdminAPI')
                }

                $DependsOn += @(
                    '[xCredSSP]Client', 
                    '[xCredSSP]Server', 
                    '[cAzurePackSetup]TenantSiteInstall'
                )

                cAzurePackSetup 'TenantSiteInitialize'
                {
                    DependsOn = $DependsOn
                    Role = 'Tenant Site'
                    Action = 'Initialize'
                    dbUser = $Node.SAPassword
                    SourcePath = $Node.WAPSourcePath
                    SourceFolder = 'Installer'
                    SetupCredential = $Node.InstallerServiceAccount
                    Passphrase = $Node.WAPackPassphrase
                    SQLServer = $WindowsAzurePack2013DatabaseServer
                    SQLInstance = $WindowsAzurePack2013DatabaseInstance
                }

                if($Node.AzurePackTenantSiteFQDN)
                {
                    cManageCertificates 'TenantSite'
                    {
                        DependsOn = '[cAzurePackSetup]TenantSiteInitialize'
                        Thumbprint = $Node.WAPCertificateThumbprint
                        Location = $Node.WAPCertificatelocation
                        Ensure = 'Present'
                        Password = $Node.WAPCertificatepassword
                        Store = 'My'
                        StoreType = 'LocalMachine'
                        Reboot = $false
                        PsDscRunAsCredential = $Node.InstallerServiceAccount
                    }
                    
                    cWebsite 'TenantSite'
                    {
                        DependsOn = '[cAzurePackSetup]TenantSiteInitialize'
                        Name = 'MgmtSvc-TenantSite'
                        Ensure = 'Present'
                        State = 'Started'
                        PhysicalPath = 'C:\inetpub\MgmtSvc-TenantSite'
                        BindingInfo = cWebBindingInformation
                                      {
                                      Protocol = 'HTTPS'
                                      Port = $Node.AzurePackTenantSitePort
                                      HostName = $Node.AzurePackTenantSiteFQDN
                                      CertificateThumbprint = $Node.WAPCertificateThumbprint
                                      CertificateStoreName = 'My'
                                      }
                    }
                    
                    cAzurePackFQDN 'TenantSite'
                    {
                        DependsOn = '[cAzurePackSetup]TenantSiteInitialize'
                        Namespace = 'TenantSite'
                        FullyQualifiedDomainName = $Node.AzurePackTenantSiteFQDN
                        Port = $Node.AzurePackTenantSitePort
                        AzurePackAdminCredential = $Node.InstallerServiceAccount
                        SQLServer = $WindowsAzurePack2013DatabaseServer
                        SQLInstance = $WindowsAzurePack2013DatabaseInstance
                        dbUser = $Node.SAPassword
                    }

                    cAzurePackIdentityProvider 'TenantSite'
                    {
                        DependsOn = '[cAzurePackSetup]TenantSiteInitialize'
                        Target = 'Membership'
                        FullyQualifiedDomainName = $Node.AzurePackTenantSiteFQDN
                        Port = $Node.AzurePackTenantSitePort
                        AzurePackAdminCredential = $Node.InstallerServiceAccount
                        SQLServer = $WindowsAzurePack2013DatabaseServer
                        SQLInstance = $WindowsAzurePack2013DatabaseInstance
                        dbUser = $Node.SAPassword
                    }
                }
            }
            else
            {
                WaitForAll 'TenantSiteInitialize'
                {
                    NodeName = $WindowsAzurePack2013TenantSiteServers[0]
                    ResourceName = '[cAzurePackSetup]TenantSiteInitialize'
                    PsDscRunAsCredential = $Node.InstallerServiceAccount
                    RetryCount = 720
                    RetryIntervalSec = 20
                }

                cAzurePackSetup 'TenantSiteInitialize'
                {
                    DependsOn = @(
                        '[xCredSSP]Client', 
                        '[xCredSSP]Server', 
                        '[cAzurePackSetup]TenantSiteInstall', 
                        '[WaitForAll]TenantSiteInitialize'
                    )
                    Role = 'Tenant Site'
                    Action = 'Initialize'
                    dbUser = $Node.SAPassword
                    SourcePath = $Node.WAPSourcePath
                    SourceFolder = 'Installer'
                    SetupCredential = $Node.InstallerServiceAccount
                    Passphrase = $Node.WAPackPassphrase
                    SQLServer = $WindowsAzurePack2013DatabaseServer
                    SQLInstance = $WindowsAzurePack2013DatabaseInstance
                }
            }
        }

        # Install and initialize Azure Pack Tenant Authentication Site
        if(
            ($WindowsAzurePack2013TenantAuthenticationSiteServers | Where-Object -FilterScript {
                    $_ -eq $Node.NodeName
            })
        )
        {
            cAzurePackSetup 'TenantAuthenticationSiteInstall'
            {
                Role = 'Tenant Authentication Site'
                Action = 'Install'
                SourcePath = $Node.WAPSourcePath
                SourceFolder = 'Installer'
                SetupCredential = $Node.InstallerServiceAccount
                Passphrase = $Node.WAPackPassphrase
            }

            $DependsOn = @()

            if(
                ($WindowsAzurePack2013TenantAuthenticationSiteServers[0] -eq $Node.NodeName)
            )
            {
                # Wait for Tenant Public API
                if ($WindowsAzurePack2013TenantAuthenticationSiteServers[0] -eq $WindowsAzurePack2013TenantPublicAPIServers[0])
                {
                    $DependsOn = @('[cAzurePackSetup]TenantPublicAPIInitialize')
                }
                else
                {
                    WaitForAll 'AdminAPI'
                    {
                        NodeName = $WindowsAzurePack2013TenantPublicAPIServers[0]
                        ResourceName = ('[cAzurePackSetup]TenantPublicAPIInitialize')
                        PsDscRunAsCredential = $Node.InstallerServiceAccount
                        RetryCount = 720
                        RetryIntervalSec = 20
                    }
                    $DependsOn = @('[WaitForAll]AdminAPI')
                }

                $DependsOn += @(
                    '[xCredSSP]Client', 
                    '[xCredSSP]Server', 
                    '[cAzurePackSetup]TenantAuthenticationSiteInstall'
                )

                cAzurePackSetup 'TenantAuthenticationSiteInitialize'
                {
                    DependsOn = $DependsOn
                    Role = 'Tenant Authentication Site'
                    Action = 'Initialize'
                    dbUser = $Node.SAPassword
                    SourcePath = $Node.WAPSourcePath
                    SourceFolder = 'Installer'
                    SetupCredential = $Node.InstallerServiceAccount
                    Passphrase = $Node.WAPackPassphrase
                    SQLServer = $WindowsAzurePack2013DatabaseServer
                    SQLInstance = $WindowsAzurePack2013DatabaseInstance
                }

                if($Node.AzurePackAuthSiteFQDN)
                {
                    if ($WindowsAzurePack2013TenantAuthenticationSiteServers[0] -ne $WindowsAzurePack2013TenantSiteServers[0])
                    {                    
                        cManageCertificates 'TenantAuthenticationSite'
                        {
                            DependsOn = '[cAzurePackSetup]TenantAuthenticationSiteInitialize'
                            Thumbprint = $Node.WAPCertificateThumbprint
                            Location = $Node.WAPCertificatelocation
                            Ensure = 'Present'
                            Password = $Node.WAPCertificatepassword
                            Store = 'My'
                            StoreType = 'LocalMachine'
                            Reboot = $false
                            PsDscRunAsCredential = $Node.InstallerServiceAccount
                        }
                    }                  
                    
                    cWebsite 'TenantAuthenticationSite'
                    {
                        DependsOn = '[cAzurePackSetup]TenantAuthenticationSiteInitialize'
                        Name = 'MgmtSvc-AuthSite'
                        Ensure = 'Present'
                        State = 'Started'
                        PhysicalPath = 'C:\inetpub\MgmtSvc-AuthSite'
                        BindingInfo = cWebBindingInformation
                                      {
                                      Protocol = 'HTTPS'
                                      Port = $Node.AzurePackAuthSitePort
                                      HostName = $Node.AzurePackAuthSiteFQDN
                                      CertificateThumbprint = $Node.WAPCertificateThumbprint
                                      CertificateStoreName = 'My'
                                      }
                    }
                    
                    cAzurePackFQDN 'TenantAuthenticationSite'
                    {
                        DependsOn = '[cAzurePackSetup]TenantAuthenticationSiteInitialize'
                        Namespace = 'AuthSite'
                        Port = $Node.AzurePackAuthSitePort
                        FullyQualifiedDomainName = $Node.AzurePackAuthSiteFQDN
                        AzurePackAdminCredential = $Node.InstallerServiceAccount
                        SQLServer = $WindowsAzurePack2013DatabaseServer
                        SQLInstance = $WindowsAzurePack2013DatabaseInstance
                        dbUser = $Node.SAPassword
                    }

                    cAzurePackRelyingParty 'TenantAuthenticationSite'
                    {
                        DependsOn = '[cAzurePackSetup]TenantAuthenticationSiteInitialize'
                        Target = 'Tenant'
                        FullyQualifiedDomainName = $Node.AzurePackAuthSiteFQDN
                        AzurePackAdminCredential = $Node.InstallerServiceAccount
                        SQLServer = $WindowsAzurePack2013DatabaseServer
                        SQLInstance = $WindowsAzurePack2013DatabaseInstance
                        dbUser = $Node.SAPassword
                    }
                }
            }
            else
            {
                WaitForAll 'TenantAuthenticationSiteInitialize'
                {
                    NodeName = $WindowsAzurePack2013TenantAuthenticationSiteServers[0]
                    ResourceName = '[cAzurePackSetup]TenantAuthenticationSiteInitialize'
                    PsDscRunAsCredential = $Node.InstallerServiceAccount
                    RetryCount = 720
                    RetryIntervalSec = 20
                }

                cAzurePackSetup 'TenantAuthenticationSiteInitialize'
                {
                    DependsOn = @(
                        '[xCredSSP]Client', 
                        '[xCredSSP]Server', 
                        '[cAzurePackSetup]TenantAuthenticationSiteInstall', 
                        '[WaitForAll]TenantAuthenticationSiteInitialize'
                    )
                    Role = 'Tenant Authentication Site'
                    Action = 'Initialize'
                    dbUser = $Node.SAPassword
                    SourcePath = $Node.WAPSourcePath
                    SourceFolder = 'Installer'
                    SetupCredential = $Node.InstallerServiceAccount
                    Passphrase = $Node.WAPackPassphrase
                    SQLServer = $WindowsAzurePack2013DatabaseServer
                    SQLInstance = $WindowsAzurePack2013DatabaseInstance
                }
            }
        }

    }
}

$ConfigurationData = @{
    AllNodes = @(
        @{
            NodeName                        = '*'
            PSDscAllowDomainUser            = $true
            PSDSCAllowPlaintextpassword     = $true
            SQLSourcePath                   = '\\labfileshare\Data'
            SQLSourceFolder                 = 'SQLServer\2014'
            SQLSysadmins                    = @('Administrator', 'LAB\MSSQL_Administrators')
            WAPSourcePath                   = '\\labfileshare\Data\WAP'
            InstallerServiceAccount         = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ('LAB\Administrator', $InstallerPassword)
            AdminAccount                    = '.\MSSQL_Administrators'
            SAPassword                      = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ('SA', $ServerAdminPassword)
            AzurePackAdministratorsGroup    = 'LAB\WAP_Administrators'
            WAPackPassphrase                = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ('notrequired', $WAPPassphrase)
            AzurePackTenantSiteFQDN         = 'portal.LAB.local'
            AzurePackAdminSiteFQDN          = 'admin.LAB.local'
            AzurePackAuthSiteFQDN           = 'auth.LAB.local'
            AzurePackWindowsAuthSiteFQDN    = 'adminauth.LAB.local'
            AzurePackTenantAPIFQDN          = 'wapapi.LAB.local'
            AzurePackAdminAPIFQDN           = 'wapadminapi.LAB.local'
            AzurePackTenantPublicAPIFQDN    = 'pubapi.LAB.local'
            AzurePackSQLServerExtensionFQDN = 'wapsql.LAB.local'
            AzurePackMySQLExtensionFQDN     = 'wapmysql.LAB.local'
            AzurePackAdminAPIPort           = 30004
            AzurePackTenantAPIPort          = 30005
            AzurePackTenantPublicAPIPort    = 30006
            AzurePackMarketplacePort        = 30018
            AzurePackMonitoringPort         = 30020
            AzurePackUsageServicePort       = 30022
            AzurePackSQLServerExtensionPort = 30010
            AzurePackMySQLExtensionPort     = 30012
            AzurePackAuthSitePort           = 30071
            AzurePackWindowsAuthSitePort    = 30072
            AzurePackTenantSitePort         = 443
            AzurePackAdminSitePort          = 443
            WAPCertificatelocation          = '\\labfileshare\Data\WAP\Prerequisites\WAP.pfx'
            WAPCertificateThumbprint        = '1a10106c6d53119788105e45f81305c382e44d34'
            WAPCertificatepassword          = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ('LAB\Administrator', $InstallerPassword)
        }

        @{
            NodeName   = 'Databaseserver'
            NodeGuid   = 'ce553425-8ff2-4dd0-94c8-80427696b8fa'
            Roles      = @(
                'Windows Azure Pack 2013 Database Server'
            )
            SQLServers = @(
                @{
                    Roles          = @('Windows Azure Pack 2013 Database Server')
                    InstanceName   = 'MSSQLSERVER'
                    Serviceaccount = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ('SRV_MSSQL', (ConvertTo-SecureString -String '$erv1ceP$$wd!' -AsPlainText -Force))
                }
            )
        }
        @{
            NodeName   = 'TenantAPI'
            NodeGuid   = 'e047c414-2bfc-48d8-bf15-dc84575f9315'
            Roles      = @(
                'Windows Azure Pack 2013 Tenant API Server'
            )
        }
        @{
            NodeName   = 'AdminAPI_SQLext_MYSQLext'
            NodeGuid   = 'd7f7f1f3-8910-4b8e-bb5a-0c677d0aac0e'
            Roles      = @(
                'Windows Azure Pack 2013 Admin API Server', 
                'Windows Azure Pack 2013 SQL Server Extension Server', 
                'Windows Azure Pack 2013 MySQL Extension Server'
            )
        }
        @{
            NodeName   = 'TenantSite_TenantPublicAPI_TenantAuthenticationSite'
            NodeGuid   = 'a3fb549d-873a-411c-a71a-859d9c9ae4cb'
            Roles      = @(
                'Windows Azure Pack 2013 Tenant Public API Server', 
                'Windows Azure Pack 2013 Tenant Site Server', 
                'Windows Azure Pack 2013 Tenant Authentication Site Server'
            )
        }
        @{
            NodeName   = 'AdminSite_AdminAuthenticationSite'
            NodeGuid   = '434e50c2-f289-48b2-b92d-20725831f4ed'
            Roles      = @(
                'Windows Azure Pack 2013 Admin Site Server', 
                'Windows Azure Pack 2013 Admin Authentication Site Server'
            )
        }
    )
}

Example_WindowsAzurePack -ConfigurationData $ConfigurationData -OutputPath 'C:\DSC\Staging\Example_WindowsAzurePack'