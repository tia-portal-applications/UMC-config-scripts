[Console]::InputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$AUTOLOGOFFTIME = Read-Host "Please enter the value of the auto logoff time in minutes"
 
$credential = Get-Credential
 
$UMCADMIN = $credential.UserName
$UMCADMINPWD = $credential.GetNetworkCredential().Password
 
try {
        $groupListOutput = & "C:\Program Files\Siemens\UserManagement\BIN\UMX.exe" -x $UMCADMIN $UMCADMINPWD -l -g
 
        if ($LASTEXITCODE -ne 0) 
            throw "Error: Groups could not be read."
    }
} catch {
    Write-Error $_
    exit 1
}
 
$groupList = $groupListOutput | Select-String -Pattern '#\d+' | ForEach-Object { $_.Line -replace '.*#\d+\s*', '' }
 
foreach ($group in $groupList) {
 
    try {
            $groupDataOutput = & "C:\Program Files\Siemens\UserManagement\BIN\UMX.exe" -x $UMCADMIN $UMCADMINPWD -i -g $group -s
            if ($LASTEXITCODE -ne 0) {
                throw "Error: The following group could not be extracted: $group"
            }
        } catch {
            Write-Error $_
            continue
        }
 
    $userList = $groupDataOutput | Select-String -Pattern 'User\s+"([^"]+)"' | ForEach-Object { $_.Matches[0].Groups[1].Value }
 
    foreach ($user in $userList) {
        try {
& "C:\Program Files\Siemens\UserManagement\BIN\UMX.exe" -x $UMCADMIN $UMCADMINPWD -U -u $user -s -al $AUTOLOGOFFTIME
            if ($LASTEXITCODE -ne 0) {
                throw "Auto logoff time could not be set for $user"
            }
        } catch {
            Write-Error $_
            continue
        }
    }
}
