@echo off
title FixMate - IT Maintenance Toolkit
color 1F

:: ====== CONFIG ======
set "VERSION=1.0.2"
set "REPO=https://raw.githubusercontent.com/esi0077/fixmate/main"
set "REPO_VERSION=%REPO%/version.txt"
set "REPO_BAT=%REPO%/fixmate.bat"
set "REMOTE_VERSION_FILE=%TEMP%\fixmate_version.txt"
set "REMOTE_SCRIPT=%TEMP%\fixmate_new.bat"

:: ====== AUTO-UPDATE ======
echo Checking for updates...

:: Download latest version number
powershell -Command "try { Invoke-WebRequest -Uri '%REPO_VERSION%' -OutFile '%REMOTE_VERSION_FILE%' -UseBasicParsing } catch { exit 1 }"

if not exist "%REMOTE_VERSION_FILE%" (
    echo [WARNING] Could not check for updates. Continuing with local version.
    goto :MENU
)

set /p LATEST_VERSION=<"%REMOTE_VERSION_FILE%"
del "%REMOTE_VERSION_FILE%"

if not "%VERSION%"=="%LATEST_VERSION%" (
    echo [UPDATE] New version available: %LATEST_VERSION%
    echo Downloading update...

    powershell -Command "try { Invoke-WebRequest -Uri '%REPO_BAT%' -OutFile '%REMOTE_SCRIPT%' -UseBasicParsing } catch { exit 1 }"

    if not exist "%REMOTE_SCRIPT%" (
        echo [ERROR] Failed to download updated script.
        pause
        goto :MENU
    )

    echo Updating FixMate...
    copy /y "%REMOTE_SCRIPT%" "%~f0" >nul
    del "%REMOTE_SCRIPT%"

    echo Restarting FixMate...
    start "" "%~f0"
    exit
)
:: ====== END AUTO-UPDATE ======




:MENU
cls
echo ==================================================
echo                 FixMate - IT Tools
echo ==================================================
echo 1. Check Serial Number
echo 2. Check HWID
echo 3. Clear System Cache
echo 4. Clear Microsoft Office Logins
echo 5. Clear Microsoft App Local Cache
echo 6. Restart Network Adapter and Bluetooth
echo 0. Exit
echo ==================================================
set /p choice=Choose an option:

if "%choice%"=="1" goto serial
if "%choice%"=="2" goto hwid
if "%choice%"=="3" goto clearcache
if "%choice%"=="4" goto clearoffice
if "%choice%"=="5" goto clearmscache
if "%choice%"=="6" goto restartnet
if "%choice%"=="0" exit
goto MENU

:serial
cls
echo Serial Number:
wmic bios get serialnumber
pause
goto MENU

:hwid
cls
echo HWID:
wmic csproduct get uuid
pause
goto MENU

:clearcache
cls
echo Clearing temp folders, DNS cache and clipboard...
del /q /f /s "%temp%\*" >nul 2>&1
del /q /f /s "C:\Windows\Temp\*" >nul 2>&1
ipconfig /flushdns
echo. | clip
echo Cache cleared.
pause
goto MENU

:clearoffice
cls
echo Clearing Microsoft Office logins...
cmdkey /list | findstr /i "MicrosoftOffice" > tempkeys.txt
for /f "tokens=5 delims=:" %%i in ('findstr /i "Target" tempkeys.txt') do cmdkey /delete:%%i
del tempkeys.txt
echo Office credentials cleared.
pause
goto MENU

:clearmscache
cls
echo Deleting Microsoft apps' local cache...
rd /s /q "%LOCALAPPDATA%\Microsoft\OneDrive"
rd /s /q "%LOCALAPPDATA%\Microsoft\Teams"
rd /s /q "%APPDATA%\Microsoft\Teams"
rd /s /q "%LOCALAPPDATA%\Packages\Microsoft.MicrosoftOfficeHub_*"
rd /s /q "%LOCALAPPDATA%\Packages\Microsoft.Office.OneNote_*"
echo Cache deleted.
pause
goto MENU

:restartnet
cls
echo Restarting network adapter and Bluetooth...

:: Replace "Wi-Fi" with your adapter name if different
netsh interface set interface "Wi-Fi" admin=disable
timeout /t 2 >nul
netsh interface set interface "Wi-Fi" admin=enable

net stop bthserv >nul 2>&1
net start bthserv >nul 2>&1

echo Adapters restarted.
pause
goto MENU