@ECHO OFF

REM -- Elevate permissions here --

NET SESSION >NUL 2>&1
IF "%ERRORLEVEL%" == "0" (GOTO WARNING) ELSE (GOTO ELEVATEPERM)

:ELEVATEPERM
IF EXIST "%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" (
POWERSHELL.EXE -C "& {Start-Process \"%~f0\" -WorkingDirectory \"%~dp0\\" -Verb \"RunAs\"}" >NUL 2>&1
) ELSE (
ECHO Your system doesn't have PowerShell installed.
)
GOTO EOFNOCLS

REM -- The real functions are all under here --

:ENABLEDLL
IF NOT EXIST "%SystemRoot%\System32\%~1.d" (EXIT /B)
TAKEOWN /F "%SystemRoot%\System32\%~1.d" /A
ICACLS "%SystemRoot%\System32\%~1.d" /GRANT:R *S-1-5-32-544:(F) /C
REN "%SystemRoot%\System32\%~1.d" "%~1"
ICACLS "%SystemRoot%\System32\%~1" /SETOWNER *S-1-5-80-956008885-3418522649-1831038044-1853292631-2271478464 /C
IF NOT EXIST "%SystemRoot%\System32\%~1.acls" (EXIT /B)
ICACLS "%SystemRoot%\System32" /RESTORE "%SystemRoot%\System32\%~1.acls" /C
DEL /Q "%SystemRoot%\System32\%~1.acls"
EXIT /B

:DISABLEDLL
IF NOT EXIST "%SystemRoot%\System32\%~1" (EXIT /B)
ICACLS "%SystemRoot%\System32\%~1" /SAVE "%SystemRoot%\System32\%~1.acls" /C
TAKEOWN /F "%SystemRoot%\System32\%~1" /A
ICACLS "%SystemRoot%\System32\%~1" /GRANT:R *S-1-5-32-544:(F) /C
REN "%SystemRoot%\System32\%~1" "%~1.d"
ICACLS "%SystemRoot%\System32\%~1.d" /SETOWNER *S-1-5-80-956008885-3418522649-1831038044-1853292631-2271478464 /C
ICACLS "%SystemRoot%\System32\%~1.d" /GRANT:R *S-1-5-32-544:(RX) /C
EXIT /B

:SETCMDSHELL
IF "%~1" == "1" (
REG ADD "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /F /V Shell /T REG_SZ /D "cmd.exe /C \"cd /D \"%%USERPROFILE%%\" ^& start cmd.exe /K runonce.exe /AlternateShellStartup\""
) ELSE (
REG ADD "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /F /V Shell /T REG_SZ /D "explorer.exe"
)
EXIT /B

:CONVERTENV
CLS
COLOR 07
ECHO %~1
ECHO ========================================================================================================================
CALL %~2 "%~3"
CALL %~4 "%~5"
CALL :SETCMDSHELL "%~6"
ECHO ========================================================================================================================
ECHO.
ECHO Finished! Don't forget to restart your session for the changes to apply.
SET MUTEINVALID=1
EXIT /B

REM -- Menu related functions --

:DISPLAYMENUHEADER
CLS
COLOR 1F
ECHO  +-------------------------------------------------------------------------+
ECHO  ^|      Welcome to the Windows Minimal Environment conversion script.      ^|
ECHO  ^| This script allows you to use a more minimal shell instead of Explorer. ^|
ECHO  +-------------------------------------------------------------------------+
ECHO.
ECHO.
EXIT /B

:DISPLAYINVALID
IF "%MUTEINVALID%" == "1" (EXIT /B)
ECHO Invalid selection!
ECHO.
EXIT /B

:USERCHOICEPOPUP
SET MUTEINVALID=
SET USERCHOICE=
SET /P USERCHOICE=Select: 
EXIT /B

REM -- Each individual menu and the available options to be processed --

:MENU0
CALL :DISPLAYMENUHEADER
ECHO  Main Menu:
ECHO  1^> Minimal Environment
ECHO  2^> Normal Environment
ECHO  3^> [Exit]
ECHO.
CALL :USERCHOICEPOPUP
GOTO PROCESS0

:MENU1
CALL :DISPLAYMENUHEADER
ECHO  Minimal Environment:
ECHO  1^> With DWM
ECHO  2^> Without DWM (Unstable)
ECHO  3^> [Return]
ECHO.
CALL :USERCHOICEPOPUP
GOTO PROCESS1

:MENU2
CALL :DISPLAYMENUHEADER
ECHO  Normal Environment:
ECHO  1^> Graphical LogonUI (Windows Default)
ECHO  2^> Console LogonUI
ECHO  3^> [Return]
ECHO.
CALL :USERCHOICEPOPUP
GOTO PROCESS2

:PROCESS0
IF "%USERCHOICE%" == "1" (GOTO MENU1)
IF "%USERCHOICE%" == "2" (GOTO MENU2)
IF "%USERCHOICE%" == "3" (GOTO EOF)
CALL :DISPLAYINVALID
PAUSE
GOTO MENU0

:PROCESS1
IF "%USERCHOICE%" == "1" (
CALL :CONVERTENV "Converting to Minimal Environment (With DWM)..." ":ENABLEDLL" "dwminit.dll" ":DISABLEDLL" "Windows.UI.Logon.dll" "1"
)
IF "%USERCHOICE%" == "2" (
CALL :CONVERTENV "Converting to Minimal Environment (Without DWM)..." ":DISABLEDLL" "dwminit.dll" ":DISABLEDLL" "Windows.UI.Logon.dll" "1"
)
IF "%USERCHOICE%" == "3" (GOTO MENU0)
CALL :DISPLAYINVALID
PAUSE
GOTO MENU1

:PROCESS2
IF "%USERCHOICE%" == "1" (
CALL :CONVERTENV "Converting to Normal Environment (Graphical LogonUI)..." ":ENABLEDLL" "dwminit.dll" ":ENABLEDLL" "Windows.UI.Logon.dll" "0"
)
IF "%USERCHOICE%" == "2" (
CALL :CONVERTENV "Converting to Normal Environment (Console LogonUI)..." ":ENABLEDLL" "dwminit.dll" ":DISABLEDLL" "Windows.UI.Logon.dll" "0"
)
IF "%USERCHOICE%" == "3" (GOTO MENU0)
CALL :DISPLAYINVALID
PAUSE
GOTO MENU2

REM -- Bring up a warning menu before the main menu --

:WARNING
CLS
COLOR 0C
ECHO  +-----------------------------------------------------------------------------------------------+
ECHO  ^| This script changes system files and I'm not liable for any damage.                           ^|
ECHO  ^| If your Windows system no longer functions correctly after using this script, don't blame me. ^|
ECHO  +-----------------------------------------------------------------------------------------------+
ECHO.
ECHO.
SET /P USERCHOICE=Type 'I understand' to continue or anything else to quit: 
IF /I "%USERCHOICE%" == "i understand" (GOTO MENU0)
GOTO EOF

REM -- End-of-File stuff --

:EOF
CLS

:EOFNOCLS
SET MUTEINVALID=
SET USERCHOICE=
@ECHO ON
