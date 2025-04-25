# What is the autologoffConfigurator.bat?
The script configures the autologoff time in minutes for all users inside of the User Management Component that are part of a group.
It works for both, UMC and Active Directory groups.

## How to use
The script must be exectued as an Administrator via Command Prompt with three parameters as follows:

UMC Administrator Username | UMC Administrator Password | The new autologoff time in minutes

e.g.:
```
C:\Users\Administrator\Desktop> autologoffConfigurator.bat username password 12

Result:
User "UMCADDOMAIN\TestUser0001" updated.
Time taken: 0.03s
```

## Principle of operation
This script will **only use existing functions** of the **UMX**-Application which is a part of the UMC installation.
1. **Generate Group List:** Lists all groups and saves to group_list_temp.txt.
2. **Process Each Group:** For each group, extracts group name and saves detailed info to group_data_temp.txt.
3. **Process Each User:** For each user in the group, updates user settings based on group_data_temp.txt.
4. **Clean Up:** Deletes temporary files after processing.

## Functional limitation
The script will only set the autologoff time for users that already exist in UMC and those that are assigned to a group.
Also note that users who have been added to a group after running the script will not have an autologoff time configured until the script is manually executed again.

> **Tip:** You can find more information in the SiePortal **[UMC application example](https://support.industry.siemens.com/cs/ww/en/view/109780337)**.
