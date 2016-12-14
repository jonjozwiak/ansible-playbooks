# Usage: 
# restore_latest_mssql_db.ps1 -instanceName YourInstanceName -dbName YOURDB
#
# This script will restore from the latest file in the Backup Directory

# Load command line parameters
Param(
  [Parameter(Mandatory=$True)]
    [string]$instanceName,

  [Parameter(Mandatory=$True)]
  [string]$dbName

)

# Ensure SQL Power Shell Modules are in the path
$env:PSModulePath = $env:PSModulePath + ";C:\Program Files (x86)\Microsoft SQL Server\110\Tools\PowerShell\Modules"

# Import SQL Server Module called SQLPS
Import-Module SQLPS -DisableNameChecking
 
# Your SQL Server Instance Name (Server)
$Srvr = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList $instanceName
 

# Backup database with default settings
$backupDir = "C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Backup\"
$backupFile = get-childitem -path $backupDir -Filter "$dbName.*.bak" -name | where-object { -not $_.PSIsContainer } | sort-object -Property $_.CreationTime | select-object -last 1 

Restore-SqlDatabase -ServerInstance $instanceName -Database $dbName -BackupFile $backupFile -ReplaceDatabase

