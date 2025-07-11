# ##############################################################################
# User Management Component Server - Autologoff Configurator
# ##############################################################################

# GLOBALS ######################################################################

[string]$Global:Umx = 'C:\Program Files\Siemens\UserManagement\BIN\UMX.exe'

[Console]::InputEncoding  = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# FUNCTIONS ####################################################################

<#
.SYNOPSIS
Sets the installation directory for the UMC (User Management Component).

.DESCRIPTION
Updates the global path to the executables by validating the provided directory.
Throws an error if the path is invalid.

.PARAMETER Path
The root installation directory of the UMC.

.EXAMPLE
Set-UMCInstallDirectory -Path "C:\Program Files\Siemens\UserManagement"
#>
function Set-UMCInstallDirectory {
    param(
        [Parameter(Mandatory=$true)][string]$Path
    )
    if (-not (Test-Path $Path)) {
        throw "Path not found: $Path"
    }

    $newUmxPath = [io.path]::combine($Path, 'BIN', 'UMX.exe')
    if (-not (Test-Path $newUmxPath)) {
        throw "UMX.exe not found at $newUmxPath"
    }

    $Global:Umx = $newUmxPath
}

<#
.SYNOPSIS
Sets the autologoff time for all users in all groups.

.DESCRIPTION
Authenticates with UMC, retrieves all groups, and sets the specified autologoff time for every user in every group.
Throws errors for missing credentials, invalid autologoff time, or authentication failures.

.PARAMETER Credential
A PSCredential object for authenticating with UMC.

.PARAMETER AutologoffTime
The autologoff time (in minutes) to set for all users. Must be greater than zero.

.EXAMPLE
$cred = Get-Credential
Set-UMCAutologoffAllGroups -Credential $cred -AutologoffTime 30
#>
function Set-UMCAutologoffAllGroups {
    param(
        [Parameter(Mandatory=$false)]
        [PSCredential]$Credential=$null,
        [Parameter(Mandatory=$false)]
        [int]$AutologoffTime=$null
    )
#region Validation
    if ($null -eq $Credential) {
        throw "Missing mandatory UMC credential attribute!"
    }
    if ($null -eq $AutologoffTime) {
        throw "Missing mandatory autologoff time!"
    }
    if ($AutologoffTime -lt 1) {
        throw "Invalid autologoff time /$AutologoffTime/. Must be more than zero."
    }
    if (-not (Test-Path $Global:Umx)) {
        throw "UMX.exe not found at $Global:Umx"
    }
#endregion
#region Collect groups
    $LASTEXITCODE = 0
    $groupListOutput = & "$Global:Umx" -x $Credential.UserName $Credential.GetNetworkCredential().Password -l -g
    if ($LASTEXITCODE -ne 0) {
        if ($groupListOutput -match "Error code is Error while Authenticating User. Error code is SL_WRONGUSERNAMEPASSWORD.") {
            throw "Authentication failed: Invalid username or password."
        }
        throw "Error: Groups could not be read."
    }
#endregion
    $groups = $groupListOutput | Select-String -Pattern '#\d+' | ForEach-Object { $_.Line -replace '.*#\d+\s*', '' }
    foreach ($group in $groups) {
#region Extract group
        $groupDataOutput = & "$Global:Umx" -x $Credential.UserName $Credential.GetNetworkCredential().Password -i -g $group -s
        if ($LASTEXITCODE -ne 0) {
            if ($groupDataOutput -match "Error while Authenticating User. Error code is SL_WRONGUSERNAMEPASSWORD.") {
                throw "Authentication failed: Invalid username or password."
            }
            throw "Error: The following group could not be extracted: $group"
        }
#endregion
#region Collect users and set the autologoff times
        $userList = $groupDataOutput | Select-String -Pattern 'User\s+"([^"]+)"' | ForEach-Object { $_.Matches[0].Groups[1].Value }
        foreach ($user in $userList) {
            $setResult = & "$Global:Umx" -x $Credential.UserName $Credential.GetNetworkCredential().Password -U -u $user -s -al $AutologoffTime
            if ($LASTEXITCODE -ne 0) {
                if ($setResult -match "Error while Authenticating User. Error code is SL_WRONGUSERNAMEPASSWORD.") {
                    throw "Authentication failed: Invalid username or password."
                }
                throw "Autologoff time could not be set for $user"
            }
        }
#endregion
    }
}

<#
.SYNOPSIS
Sets autologoff times for users in specified groups based on a JSON file.

.DESCRIPTION
Authenticates with UMC, reads group and autologoff time data from a JSON file, and sets the autologoff time for each user in each group.
Handles errors for missing credentials, missing or invalid group data, and authentication failures.

.PARAMETER Credential
A PSCredential object for authenticating with UMC.

.PARAMETER GroupData
Path to a JSON file containing group names and autologoff times.

.EXAMPLE
$cred = Get-Credential
Set-UMCAutologoffForGroups -Credential $cred -GroupData "C:\groups.json"
#>
function Set-UMCAutologoffForGroups {
    param(
        [Parameter(Mandatory=$false)]
        [PSCredential]$Credential=$null,
        [Parameter(Mandatory=$false)]
        [string]$GroupData=$null
    )
#region Validation
    if ($null -eq $Credential) {
        throw "Missing mandatory UMC credential attribute!"
    }
    if ($null -eq $GroupData) {
        throw "Missing mandatory group data file!"
    }
    if (-not (Test-Path $GroupData)) {
        throw "The group data file is not found: $GroupData"
    }
    if (-not (Test-Path $Global:Umx)) {
        throw "UMX.exe not found at $Global:Umx"
    }
#endregion
#region Parse group data file
    $data = Get-Content -Path $GroupData -Raw -Encoding UTF8 | ConvertFrom-Json
    if (-not $data.groups) {
        throw "Invalid JSON: 'groups' property missing."
    }
#endregion
    [bool]$hadErrors=$false
    foreach ($groupObj in $data.groups) {
#region Extract group
        $group = $groupObj.groupName
        $AutologoffTime = $groupObj.autologoffTime
        $groupDataOutput = & "$Global:Umx" -x $Credential.UserName $Credential.GetNetworkCredential().Password -i -g $group -s
        if ($LASTEXITCODE -ne 0) {
            if ($groupDataOutput -match "Error while Authenticating User. Error code is SL_WRONGUSERNAMEPASSWORD.") {
                throw "Authentication failed: Invalid username or password."
            }
            Write-Error "Error: The following group could not be extracted: $group"
            $hadErrors=$true
            continue
        }
#endregion
#region Collect users and set the autologoff times
        $userList = $groupDataOutput | Select-String -Pattern 'User\s+"([^"]+)"' | ForEach-Object { $_.Matches[0].Groups[1].Value }
        if (-not $userList) {
            Write-Warning "No users found in group $group"
            $hadErrors=$true
            continue
        }

        foreach ($user in $userList) {
            $setResult = & "$Global:Umx" -x $Credential.UserName $Credential.GetNetworkCredential().Password -U -u $user -s -al $AutologoffTime
            if ($LASTEXITCODE -ne 0) {
                if ($setResult -match "Error while Authenticating User. Error code is SL_WRONGUSERNAMEPASSWORD.") {
                    throw "Authentication failed: Invalid username or password."
                }
                Write-Error "Autologoff time could not be set for $user"
                $hadErrors=$true
                continue
            }
        }
#endregion
    }
    if ($true -eq $hadErrors) {
        Write-Warning "Some auto logoff times could not be set. Check the error messages above."
    }
}

# EXPORTS ######################################################################

Export-ModuleMember -Function `
    Set-UMCInstallDirectory, `
    Set-UMCAutologoffAllGroups, `
    Set-UMCAutologoffForGroups
