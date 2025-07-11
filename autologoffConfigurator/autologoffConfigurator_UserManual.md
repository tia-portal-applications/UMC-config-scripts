# User Management Component  - Configure Autologoff for Groups PowerShell Module

This PowerShell module provides functions to manage the autologoff time in minutes for all users inside of the User Management Component (UMC) that are part of a group.
It works for both, UMC and Active Directory groups.

---

## Exported Functions

- `Set-UMCInstallDirectory`
- `Set-UMCAutologoffAllGroups`
- `Set-UMCAutologoffForGroups`

---

## Function Reference

### 1. `Set-UMCInstallDirectory`

**Description:**  
Sets the installation directory for UMC by specifying the path to the folder containing `BIN\UMX.exe`.

**Parameters:**
- `-Path` (string, mandatory): Path to the UMC installation directory.

**Example:**
```powershell
Set-UMCInstallDirectory -Path "C:\Program Files\Siemens\UserManagement"
```

---

### 2. `Set-UMCAutologoffAllGroups`

**Description:**  
Sets the autologoff time for all users in all groups.

**Parameters:**
- `-Credential` (PSCredential, mandatory): Credential object for authentication.
- `-AutologoffTime` (int, mandatory): Autologoff time in minutes.

**Example:**
```powershell
$cred = Get-Credential
Set-UMCAutologoffAllGroups -Credential $cred -AutologoffTime 30
```

---

### 3. `Set-UMCAutologoffForGroups`

**Description:**  
Sets the autologoff time for users in specified groups, as defined in the JSON file.

**Parameters:**
- `-Credential` (PSCredential, mandatory): Credential object for authentication.
- `-GroupData` (string, mandatory): Path to the JSON file with group and autologoff time definitions.

**Example JSON file (`groupData.json`):**
```json
{
  "groups": [
    { "groupName": "Admins", "autologoffTime": 10 },
    { "groupName": "Operators", "autologoffTime": 20 },
    { "groupName": "DOMAIN\\Engineers", "autologoffTime": 30 }
  ]
}
```

**Example usage:**
```powershell
$cred = Get-Credential
Set-UMCAutologoffForGroups -Credential $cred -GroupData "C:\path\to\groupData.json"
```

---

## Notes
- You must have the correct permissions and a valid UMC credential to use these functions.
- Ensure `UMX.exe` is present in the specified directory.
- Error and warning messages will be displayed if operations fail.
- For Active Directory groups, ensure the domain name is followed by a double backslash (`\\`), not a single backslash (`\`). For example: `"DOMAIN\\GroupName"`.
- If a user belongs to multiple groups, the autologoff time will be set according to the configuration of the last group in the JSON file to which the user belongs.


## Functional limitation:
The script will only set the autologoff time for users that already exist in UMC and those that are assigned to a group.
Also note that users who have been added to a group after running the script will not have an autologoff time configured until the script is manually executed again.

> **Tip:** You can find more information in the SiePortal **[UMC application example](https://support.industry.siemens.com/cs/ww/en/view/109780337)**.