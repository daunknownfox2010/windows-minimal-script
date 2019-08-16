@ECHO OFF

NET SESSION >NUL 2>&1
IF "%ERRORLEVEL%" == "0" (GOTO WARNING) ELSE (GOTO ELEVATEPERM)

:ELEVATEPERM
IF EXIST "%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" (
POWERSHELL.EXE -C "& {Start-Process \"%~f0\" -WorkingDirectory \"%~dp0\\" -Verb \"RunAs\"}" >NUL 2>&1
) ELSE (
ECHO Your system doesn't have PowerShell installed.
)
GOTO EOFNOCLS

:ENABLEDWM
TAKEOWN /F "%SystemRoot%\System32\dwminit.dll.d" /A
ICACLS "%SystemRoot%\System32\dwminit.dll.d" /GRANT:R *S-1-5-32-544:(F) /C
REN "%SystemRoot%\System32\dwminit.dll.d" "dwminit.dll"
ICACLS "%SystemRoot%\System32\dwminit.dll" /SETOWNER *S-1-5-80-956008885-3418522649-1831038044-1853292631-2271478464 /C
ICACLS "%SystemRoot%\System32" /RESTORE "%SystemRoot%\System32\dwminit.dll.acls" /C
DEL /Q "%SystemRoot%\System32\dwminit.dll.acls"
EXIT /B

:DISABLEDWM
ICACLS "%SystemRoot%\System32\dwminit.dll" /SAVE "%SystemRoot%\System32\dwminit.dll.acls" /C
TAKEOWN /F "%SystemRoot%\System32\dwminit.dll" /A
ICACLS "%SystemRoot%\System32\dwminit.dll" /GRANT:R *S-1-5-32-544:(F) /C
REN "%SystemRoot%\System32\dwminit.dll" "dwminit.dll.d"
ICACLS "%SystemRoot%\System32\dwminit.dll.d" /SETOWNER *S-1-5-80-956008885-3418522649-1831038044-1853292631-2271478464 /C
ICACLS "%SystemRoot%\System32\dwminit.dll.d" /GRANT:R *S-1-5-32-544:(RX) /C
EXIT /B

:ENABLELOGONUI
TAKEOWN /F "%SystemRoot%\System32\Windows.UI.Logon.dll.d" /A
ICACLS "%SystemRoot%\System32\Windows.UI.Logon.dll.d" /GRANT:R *S-1-5-32-544:(F) /C
REN "%SystemRoot%\System32\Windows.UI.Logon.dll.d" "Windows.UI.Logon.dll"
ICACLS "%SystemRoot%\System32\Windows.UI.Logon.dll" /SETOWNER *S-1-5-80-956008885-3418522649-1831038044-1853292631-2271478464 /C
ICACLS "%SystemRoot%\System32" /RESTORE "%SystemRoot%\System32\Windows.UI.Logon.dll.acls" /C
DEL /Q "%SystemRoot%\System32\Windows.UI.Logon.dll.acls"
EXIT /B

:DISABLELOGONUI
ICACLS "%SystemRoot%\System32\Windows.UI.Logon.dll" /SAVE "%SystemRoot%\System32\Windows.UI.Logon.dll.acls" /C
TAKEOWN /F "%SystemRoot%\System32\Windows.UI.Logon.dll" /A
ICACLS "%SystemRoot%\System32\Windows.UI.Logon.dll" /GRANT:R *S-1-5-32-544:(F) /C
REN "%SystemRoot%\System32\Windows.UI.Logon.dll" "Windows.UI.Logon.dll.d"
ICACLS "%SystemRoot%\System32\Windows.UI.Logon.dll.d" /SETOWNER *S-1-5-80-956008885-3418522649-1831038044-1853292631-2271478464 /C
ICACLS "%SystemRoot%\System32\Windows.UI.Logon.dll.d" /GRANT:R *S-1-5-32-544:(RX) /C
EXIT /B

:MINIMAL0
CLS
COLOR 0F
ECHO Converting to Minimal Environment (With DWM)...
ECHO ========================================================================================================================
IF EXIST "%SystemRoot%\System32\dwminit.dll.d" (CALL :ENABLEDWM)
IF EXIST "%SystemRoot%\System32\Windows.UI.Logon.dll" (CALL :DISABLELOGONUI)
REG ADD "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /F /V Shell /T REG_SZ /D "cmd.exe /C \"cd /D \"%%USERPROFILE%%\" ^& start cmd.exe /K runonce.exe /AlternateShellStartup\""
ECHO ========================================================================================================================
ECHO.
ECHO Finished! Don't forget to restart your session for the changes to apply.
PAUSE
GOTO MENU0

:MINIMAL1
CLS
COLOR 0F
ECHO Converting to Minimal Environment (Without DWM)...
ECHO ========================================================================================================================
IF EXIST "%SystemRoot%\System32\dwminit.dll" (CALL :DISABLEDWM)
IF EXIST "%SystemRoot%\System32\Windows.UI.Logon.dll" (CALL :DISABLELOGONUI)
REG ADD "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /F /V Shell /T REG_SZ /D "cmd.exe /C \"cd /D \"%%USERPROFILE%%\" ^& start cmd.exe /K runonce.exe /AlternateShellStartup\""
ECHO ========================================================================================================================
ECHO.
ECHO Finished! Don't forget to restart your session for the changes to apply.
PAUSE
GOTO MENU0

:NORMAL0
CLS
COLOR 0F
ECHO Converting to Normal Environment (Graphical LogonUI)...
ECHO ========================================================================================================================
IF EXIST "%SystemRoot%\System32\dwminit.dll.d" (CALL :ENABLEDWM)
IF EXIST "%SystemRoot%\System32\Windows.UI.Logon.dll.d" (CALL :ENABLELOGONUI)
REG ADD "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /F /V Shell /T REG_SZ /D "explorer.exe"
ECHO ========================================================================================================================
ECHO.
ECHO Finished! Don't forget to restart your session for the changes to apply.
PAUSE
GOTO MENU0

:NORMAL1
CLS
COLOR 0F
ECHO Converting to Normal Environment (Console LogonUI)...
ECHO ========================================================================================================================
IF EXIST "%SystemRoot%\System32\dwminit.dll.d" (CALL :ENABLEDWM)
IF EXIST "%SystemRoot%\System32\Windows.UI.Logon.dll" (CALL :DISABLELOGONUI)
REG ADD "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /F /V Shell /T REG_SZ /D "explorer.exe"
ECHO ========================================================================================================================
ECHO.
ECHO Finished! Don't forget to restart your session for the changes to apply.
PAUSE
GOTO MENU0

:MENU0
CLS
COLOR 1F
ECHO  +-------------------------------------------------------------------------+
ECHO  ^|      Welcome to the Windows Minimal Environment conversion script.      ^|
ECHO  ^| This script allows you to use a more minimal shell instead of Explorer. ^|
ECHO  +-------------------------------------------------------------------------+
ECHO.
ECHO.
ECHO  Main Menu:
ECHO  1^> Minimal Environment
ECHO  2^> Normal Environment
ECHO  3^> [Exit]
ECHO.
SET USERCHOICE=
SET /P USERCHOICE=Select: 
GOTO PROCESS0

:MENU1
CLS
ECHO  +-------------------------------------------------------------------------+
ECHO  ^|      Welcome to the Windows Minimal Environment conversion script.      ^|
ECHO  ^| This script allows you to use a more minimal shell instead of Explorer. ^|
ECHO  +-------------------------------------------------------------------------+
ECHO.
ECHO.
ECHO  Minimal Environment:
ECHO  1^> With DWM
ECHO  2^> Without DWM (Unstable)
ECHO  3^> [Return]
ECHO.
SET USERCHOICE=
SET /P USERCHOICE=Select: 
GOTO PROCESS1

:MENU2
CLS
ECHO  +-------------------------------------------------------------------------+
ECHO  ^|      Welcome to the Windows Minimal Environment conversion script.      ^|
ECHO  ^| This script allows you to use a more minimal shell instead of Explorer. ^|
ECHO  +-------------------------------------------------------------------------+
ECHO.
ECHO.
ECHO  Normal Environment:
ECHO  1^> Graphical LogonUI (Windows Default)
ECHO  2^> Console LogonUI
ECHO  3^> [Return]
ECHO.
SET USERCHOICE=
SET /P USERCHOICE=Select: 
GOTO PROCESS2

:PROCESS0
IF "%USERCHOICE%" == "1" (GOTO MENU1)
IF "%USERCHOICE%" == "2" (GOTO MENU2)
IF "%USERCHOICE%" == "3" (GOTO EOF)
ECHO Invalid selection!
ECHO.
PAUSE
GOTO MENU0

:PROCESS1
IF "%USERCHOICE%" == "1" (GOTO MINIMAL0)
IF "%USERCHOICE%" == "2" (GOTO MINIMAL1)
IF "%USERCHOICE%" == "3" (GOTO MENU0)
ECHO Invalid selection!
ECHO.
PAUSE
GOTO MENU1

:PROCESS2
IF "%USERCHOICE%" == "1" (GOTO NORMAL0)
IF "%USERCHOICE%" == "2" (GOTO NORMAL1)
IF "%USERCHOICE%" == "3" (GOTO MENU0)
ECHO Invalid selection!
ECHO.
PAUSE
GOTO MENU2

:WARNING
CLS
COLOR 0C
ECHO  +-----------------------------------------------------------------------------------------------+
ECHO  ^| This script changes system files and I'm not liable for any damage.                           ^|
ECHO  ^| If your Windows system no longer functions correctly after using this script, don't blame me. ^|
ECHO  +-----------------------------------------------------------------------------------------------+
ECHO.
ECHO.
SET USERCHOICE=
SET /P USERCHOICE="Type 'I understand' to continue or anything else to quit: "
IF /I "%USERCHOICE%" == "i understand" (GOTO MENU0)
GOTO EOF

:EOF
CLS
@ECHO ON

:EOFNOCLS
@ECHO ON
