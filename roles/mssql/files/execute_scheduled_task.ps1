# Usage: 
# execute_scheduled_task.ps1 -instanceName YourInstanceName -dbName YOURDB -jobName JOBNAME


# Load command line parameters
Param(
  [Parameter(Mandatory=$True)]
  [string]$instanceName,

  [Parameter(Mandatory=$True)]
  [string]$dbName,

  [Parameter(Mandatory=$True)]
  [string]$jobName

)

$sqlConnection = new-object System.Data.SqlClient.SqlConnection 
$sqlConnection.ConnectionString = 'server=' + $instanceName + ';integrated security=TRUE;database=' + $dbName 
$sqlConnection.Open() 
$sqlCommand = new-object System.Data.SqlClient.SqlCommand 
$sqlCommand.CommandTimeout = 120 
$sqlCommand.Connection = $sqlConnection 
$sqlCommand.CommandText= "exec msdb.dbo.sp_start_job " + $jobName 
Write-Host "Executing Job => $jobname..." 
$result = $sqlCommand.ExecuteNonQuery() 
$sqlConnection.Close()
