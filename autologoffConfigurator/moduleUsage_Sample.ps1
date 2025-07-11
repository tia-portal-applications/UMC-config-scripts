#Please ensure that you specify only a single function call, rather than invoking multiple functions as shown in the example.

# Import the module
Import-Module .\autologoffConfigurator.psm1

# Call the Set-UMCInstallDirectory function 
Set-UMCInstallDirectory -Path "C:\Program Files\Siemens\UserManagement"

# Manually specify credentials
$username = "yourUsername"
$password = "yourPassword" | ConvertTo-SecureString -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ($username, $password)

# Read JSON file
$jsonPath = "C:\path\groupData_Sample.JSON"

# Call the Set-ForGroups function 
Set-UMCAutologoffForGroups -Credential $cred -GroupData $jsonPath

# Call the Set-UMCAutologoffAllGroups function
Set-UMCAutologoffAllGroups -Credential $cred -AutologoffTime 30

# Remove the module
Remove-Module autologoffConfigurator
