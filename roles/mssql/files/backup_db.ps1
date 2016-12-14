# Usage: 
# backup_mssql_db.ps1 -instanceName YourInstanceName -dbName YOURDB

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
 
# Check if the Database Exists
$dbExists = $FALSE
foreach ($db in $Srvr.databases) {
  if ($db.name -eq $dbName) {
    Write-Host "Found Database $dbName."
    $dbExists = $TRUE
  }
}

# Backup database with default settings
if ($dbExists -eq $True) {
  $backupDir = "C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Backup\"
  $backupDate = Get-Date -f yyyyMMdd-HHmm
  $backupFile = "$backupDir$dbName.$backupDate.bak"
  #Backup-SqlDatabase -ServerInstance $instanceName -Database $dbName
  Backup-SqlDatabase -ServerInstance $instanceName -Database $dbName -BackupFile $backupFile
  # Confirm File Exists in Default location
  
  #$filetest = Test-Path "C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Backup\$dbName.bak"
  $filetest = Test-Path $backupFile
  if ($filetest -eq $True) { 
    Write-Host "Database backup created at $backupFile"
  } else { 
    Write-Host "Error - Database backup not found at $backupFile"
  }

}
