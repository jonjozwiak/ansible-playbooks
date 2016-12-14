# Usage: 
# create_user_on_db.ps1 -instanceName YourInstanceName -dbName YOURDB -dbUser YOURUSER -dbPassword YOURPASS -dbRole YOURROLE
# Where dbUser and dbPassword are the new user/password to create

# NOTE: This does not handle role ephemerally.  It should check if the user is in the role rather than always just adding...

# Load command line parameters
Param(
  [Parameter(Mandatory=$True)]
  [string]$instanceName,

  [Parameter(Mandatory=$True)]
  [string]$dbName,

  [Parameter(Mandatory=$True)]
  [string]$dbUser,

  [Parameter(Mandatory=$True)]
  [string]$dbPassword,

  [Parameter(Mandatory=$True)]
  [string]$dbRole
)

# Ensure SQL Power Shell Modules are in the path
$env:PSModulePath = $env:PSModulePath + ";C:\Program Files (x86)\Microsoft SQL Server\110\Tools\PowerShell\Modules"

# Import SQL Server Module called SQLPS
Import-Module SQLPS -DisableNameChecking
 
# Your SQL Server Instance Name (Server)
$Srvr = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList $instanceName
 
# Check if User Already Exists
$userExists = $FALSE
if ($Srvr.Logins.Contains($dbUser)) {
    Write-Host "User $dbUser already exists in $dbName."
    $userExists = $TRUE
    # Alternatively, Drop User
    # $Srvr.Logins[$dbUser].Drop()
}

# Create user
if ($userExists -eq $FALSE) {
  # Create an SMO Login object 
  $Login = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Login -ArgumentList $Srvr, $dbUser
 
  #identify what type of login this is.
  #The possible LoginTypes are AsymmetricKey, Certificate, SQLLogin, WindowsGroup, and WindowsUser
  #We are using using a SQLLogin here...
  $Login.LoginType = [Microsoft.SqlServer.Management.Smo.LoginType]::SqlLogin
 
  #Login object also has a few properties, such as PasswordPolicyEnforced and PasswordExpirationEnabled.
  $Login.PasswordExpirationEnabled = $false
  
  #Prompt the user for the password instead of hardcoding it
  #collect Password using a Read-Host cmdlet.
  #$dbPassword = Read-Host "PW" –AsSecureString
   
  $Login.Create($dbPassword)

}

# Add User and add to role 

# Confirm DB Exists 
if($Srvr.Databases.name -notcontains $dbName)
{
  Write-Host " $dbName is not a valid database on $instanceName"
  Write-Host " Databases on $Server are :"
  $Srvr.Databases|select name
  break
}

# Check Role Exists on DB 
$db = $Srvr.Databases[$dbName]
if($db.Roles.name -notcontains $dbRole)  {
    Write-Host " $dbRole is not a valid Role on $dbName on $instanceName  "
    Write-Host " Roles on $dbName are:"
    $db.roles|select name
    break
}
if(!($Srvr.Logins.Contains($dbUser))) {
    Write-Host "$dbUser not a login on $instanceName create it first"
    break
}
if (!($db.Users.Contains($dbUser)))  {
    # Add user to database
    $usr = New-Object ('Microsoft.SqlServer.Management.Smo.User') ($db, $dbUser)
    $usr.Login = $dbUser
    $usr.Create()

    #Add User to the Role
    $Rol = $db.Roles[$dbRole]
    $Rol.AddMember($dbUser)
    Write-Host "$dbUser was not a login on $dbName on $Srvr"
    Write-Host "$dbUser added to $dbName on $instanceName and $dbRole Role"
} else {
     #Add User to the Role
    $Rol = $db.Roles[$dbRole]
    $Rol.AddMember($dbUser)
    Write-Host "$dbUser added to $dbRole Role in $dbName on $instanceName"
}


