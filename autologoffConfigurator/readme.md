# What is autologoffConfigurator.ps1?
The script configures the autologoff time in minutes for all users inside of the User Management Component that are part of a group.
It works for both, UMC and Active Directory groups.

## How to use:
1. Download autologoffConfigurator.ps1 
2. Run Windows PowerShell (Administrator) and navigate to the downloaded script directory
3. Ensure your execution policy allows running scripts. You can check it with ```Get-ExecutionPolicy```  
If it's restricted, you can change it (temporarily) with ```Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass```  
5. Run the script using ```.\autologoffConfigurator.ps1```

## Principle of operation
This script will **only use existing functions** of the **UMX**-Application which is a part of the UMC installation.  
Furthermore, the script ensures UTF-8 encoding for input/output and includes a basic error handling for each major step to ensure robustness.

1. **User Input & Authentication:** Prompts the administrator to enter the desired auto logoff time (in minutes) and credentials of a user who is allowed to change user settings in UMC (e.g. UMC Admin).
2. **Group Retrieval:** Retrieve a list of all user groups.
3. **User Extraction:** For each group, extracts the list of users.
4. **Auto Logoff Configuration:** Iterates through all users and sets the specified auto logoff time.

## Functional limitation:
The script will only set the autologoff time for users that already exist in UMC and those that are assigned to a group.
Also note that users who have been added to a group after running the script will not have an autologoff time configured until the script is manually executed again.

> **Tip:** You can find more information in the SiePortal **[UMC application example](https://support.industry.siemens.com/cs/ww/en/view/109780337)**.
