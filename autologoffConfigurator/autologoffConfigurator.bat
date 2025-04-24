@ECHO OFF

SET UMCADMIN=%~1
SET UMCADMINPWD=%~2
SET AUTOLOGOFFTIME=%~3

"C:\Program Files\Siemens\UserManagement\BIN\UMX.exe" -x "%UMCADMIN%" "%UMCADMINPWD%" -l -g > "C:\Program Files\Siemens\UserManagement\BIN\group_list_temp.txt"

for /f "tokens=2" %%a in ('powershell -Command "Get-Content ''C:\Program Files\Siemens\UserManagement\BIN\group_list_temp.txt'' -Encoding UTF8 | Select-String -Pattern ''^#''"') do (
    "C:\Program Files\Siemens\UserManagement\BIN\UMX.exe" -x "%UMCADMIN%" "%UMCADMINPWD%" -i -g %%a -s > "C:\Program Files\Siemens\UserManagement\BIN\group_data_temp.txt"
    for /f "tokens=2" %%b in ('powershell -Command "Get-Content ''C:\Program Files\Siemens\UserManagement\BIN\group_data_temp.txt'' -Encoding UTF8 | Select-String -Pattern ''^User*''"') do (
        "C:\Program Files\Siemens\UserManagement\BIN\UMX.exe" -x "%UMCADMIN%" "%UMCADMINPWD%" -U -u %%b -s -al "%AUTOLOGOFFTIME%"
    )
    del "C:\Program Files\Siemens\UserManagement\BIN\group_data_temp.txt"
)

del "C:\Program Files\Siemens\UserManagement\BIN\group_list_temp.txt"
