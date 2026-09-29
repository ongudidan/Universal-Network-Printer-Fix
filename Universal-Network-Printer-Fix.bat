@echo off
setlocal EnableDelayedExpansion
title Universal Network Printer and Sharing Fix

:: Check for Administrator rights
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo ======================================================================
    echo [ERROR] This script requires Administrator privileges!
    echo Please right-click this file and select 'Run as administrator'.
    echo ======================================================================
    echo.
    pause
    exit /b 1
)

:MENU
cls
echo ======================================================================
echo          UNIVERSAL WINDOWS NETWORK PRINTER AND SHARING FIX
echo ======================================================================
echo.
echo  Please select an option:
echo.
echo  [1] Full Fix - Password Protection OFF (No Login Required)
echo      * Ideal for Home / SOHO workgroups.
echo      * Unlocks Guest, clears blank password block, fixes client guest block.
echo      * Full Network Visibility: WSD, NetBIOS, SSDP, and Firewall enabled.
echo.
echo  [2] Full Fix - Password Protection ON (Username and Password Required)
echo      * Ideal for Office / Secure environments.
echo      * Prompts connecting users for a valid Windows account and password.
echo      * Full Network Visibility: WSD, NetBIOS, SSDP, and Firewall enabled.
echo.
echo  [3] Quick Toggle Authentication and Guest Account (ON / OFF / Test)
echo      * Switch password mode or toggle Guest account to test behavior.
echo.
echo  [4] Repair Network Discovery and PC Visibility in File Explorer
echo      * Fixes "PC not showing in Network folder on other PCs".
echo      * Forces NetBIOS over TCP/IP, WSD broadcast, and discovery services.
echo.
echo  [5] Create 1-Click Connector (Pins to 'This PC' for Non-Tech Users)
echo      * Generates a double-click helper on Desktop for remote PCs.
echo      * Permanently pins this printer host directly into 'This PC'.
echo.
echo  [6] Flush Stale Network Sessions and DNS/NetBIOS Cache
echo      * Fixes persistent prompt loops caused by old cached logins.
echo.
echo  [7] Show Account Credentials and Connection Guide (For Other PCs)
echo      * View exact Username/Password formats to use on remote PCs.
echo      * Resolves Windows 11 Microsoft Account and PIN login confusion.
echo.
echo  [8] Check Current Configuration Status
echo.
echo  [9] Exit
echo.
echo ======================================================================
set /p "CHOICE=Enter your choice (1-9): "

if "%CHOICE%"=="1" goto FIX_NOPASSWORD
if "%CHOICE%"=="2" goto FIX_PASSWORD
if "%CHOICE%"=="3" goto TOGGLE_AUTH
if "%CHOICE%"=="4" goto FIX_DISCOVERY_ONLY
if "%CHOICE%"=="5" goto CREATE_SHORTCUT
if "%CHOICE%"=="6" goto FLUSH_SESSIONS
if "%CHOICE%"=="7" goto SHOW_CREDS
if "%CHOICE%"=="8" goto CHECK_STATUS
if "%CHOICE%"=="9" exit /b 0

echo.
echo [!] Invalid selection. Please choose a number from 1 to 9.
timeout /t 2 >nul
goto MENU


:: ============================================================================
:: OPTION 1: FULL FIX (NO PASSWORD REQUIRED)
:: ============================================================================
:FIX_NOPASSWORD
cls
echo ======================================================================
echo   APPLYING FULL FIX: PASSWORD PROTECTION DISABLED (GUEST ACCESS)
echo ======================================================================
echo.
call :COMMON_FIXES
call :AUTH_DISABLE_PASSWORD
call :FLUSH_CACHES
call :RESTART_SERVICES
echo.
echo ======================================================================
echo   SUCCESS! Full repair completed with Password Protection DISABLED.
echo   - PC is now discoverable and visible in File Explorer Network folder.
echo   - Guest account unlocked with blank password enabled.
echo   - Client-side insecure guest restrictions lifted.
echo   - Other PCs can connect without credential prompts.
echo   - RPC and Point-and-Print fixes (0x0000011b, 0x00000709) applied.
echo ======================================================================
echo.
pause
goto MENU


:: ============================================================================
:: OPTION 2: FULL FIX (PASSWORD REQUIRED)
:: ============================================================================
:FIX_PASSWORD
cls
echo ======================================================================
echo   APPLYING FULL FIX: PASSWORD PROTECTION ENABLED (CREDENTIALS REQUIRED)
echo ======================================================================
echo.
call :COMMON_FIXES
call :AUTH_ENABLE_PASSWORD
call :FLUSH_CACHES
call :RESTART_SERVICES
echo.
echo ======================================================================
echo   SUCCESS! Full repair completed with Password Protection ENABLED.
echo   - PC is now discoverable and visible in File Explorer Network folder.
echo   - Connecting PCs will be prompted for a valid Windows username and password.
echo   - RPC and Point-and-Print fixes (0x0000011b, 0x00000709) applied.
echo ======================================================================
echo.
echo Press any key to view the exact Login Credentials to use on other PCs...
pause >nul
goto SHOW_CREDS


:: ============================================================================
:: OPTION 3: QUICK TOGGLE AUTHENTICATION AND GUEST ACCOUNT
:: ============================================================================
:TOGGLE_AUTH
cls
echo ======================================================================
echo              TOGGLE AUTHENTICATION AND GUEST ACCOUNT
echo ======================================================================
echo.
echo  [CURRENT STATUS]
net user Guest 2>nul | findstr /i "Account active"
echo.
echo  Please select an action:
echo.
echo  [1] Turn Password Protection OFF (Full Guest Mode)
echo      * Unlocks Guest, blank passwords, and enables anonymous sharing.
echo.
echo  [2] Turn Password Protection ON (Require Username and Password)
echo      * Switches to classic authenticated mode.
echo.
echo  [3] Disable Built-in Guest Account ONLY (Test/Simulate Prompt)
echo      * Turns off Guest account without changing other registry keys.
echo      * Use this to test if client PCs immediately get password prompts.
echo.
echo  [4] Enable Built-in Guest Account ONLY
echo      * Re-activates the Guest account with a blank password.
echo.
echo  [5] Back to Main Menu
echo.
echo ======================================================================
set /p "TCHOICE=Enter your choice (1-5): "

if "%TCHOICE%"=="1" (
    echo.
    echo [*] Disabling Password-Protected Sharing...
    call :AUTH_DISABLE_PASSWORD
    call :FLUSH_CACHES
    call :RESTART_SERVICES
    echo.
    echo [+] Password protection is now TURNED OFF.
    pause
    goto MENU
)
if "%TCHOICE%"=="2" (
    echo.
    echo [*] Enabling Password-Protected Sharing...
    call :AUTH_ENABLE_PASSWORD
    call :FLUSH_CACHES
    call :RESTART_SERVICES
    echo.
    echo [+] Password protection is now TURNED ON.
    echo.
    echo Press any key to view the Login Credentials for other PCs...
    pause >nul
    goto SHOW_CREDS
)
if "%TCHOICE%"=="3" (
    echo.
    echo [*] Disabling Built-in Guest Account ONLY...
    net user Guest /active:no >nul 2>&1
    call :RESTART_SERVICES
    echo.
    echo [+] Guest account is now DISABLED.
    echo     You can now test from another PC to confirm that it prompts for credentials.
    echo.
    pause
    goto TOGGLE_AUTH
)
if "%TCHOICE%"=="4" (
    echo.
    echo [*] Enabling Built-in Guest Account ONLY...
    net user Guest /active:yes >nul 2>&1
    net user Guest "" >nul 2>&1
    net user Guest /expires:never /passwordchg:no /passwordreq:no >nul 2>&1
    reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList" /v Guest /t REG_DWORD /d 0 /f >nul 2>&1
    call :RESTART_SERVICES
    echo.
    echo [+] Guest account is now ENABLED with blank password.
    echo.
    pause
    goto TOGGLE_AUTH
)
if "%TCHOICE%"=="5" goto MENU

echo.
echo [!] Invalid selection.
timeout /t 2 >nul
goto TOGGLE_AUTH


:: ============================================================================
:: OPTION 4: REPAIR NETWORK DISCOVERY AND VISIBILITY ONLY
:: ============================================================================
:FIX_DISCOVERY_ONLY
cls
echo ======================================================================
echo        REPAIRING NETWORK DISCOVERY AND FILE EXPLORER VISIBILITY
echo ======================================================================
echo.
call :FIX_DISCOVERY_SERVICES
call :FIX_NETBIOS
call :FIX_FIREWALL
call :FLUSH_CACHES
call :RESTART_SERVICES
echo.
echo ======================================================================
echo   SUCCESS! Network Discovery and Visibility repaired.
echo   - WSD (Function Discovery) service is publishing this PC.
echo   - NetBIOS over TCP/IP is forced ON for all active network adapters.
echo   - Inbound discovery and broadcast firewall rules are active.
echo.
echo   IMPORTANT NOTE:
echo   Network Discovery is a 2-way system. If the OTHER PC still cannot see
echo   this PC in its Network list:
echo   1. Run this script on the OTHER PC as well (Option 4 or 1).
echo   2. Or on the other PC, press [F5] inside File Explorer Network folder.
echo   3. Or use Option 5 to create an instant 1-click shortcut for that PC.
echo ======================================================================
echo.
pause
goto MENU


:: ============================================================================
:: OPTION 5: CREATE 1-CLICK CONNECTOR FOR NON-TECH USERS
:: ============================================================================
:CREATE_SHORTCUT
cls
echo ======================================================================
echo     CREATE 1-CLICK CONNECTOR (PINS TO 'THIS PC' ON REMOTE COMPUTERS)
echo ======================================================================
echo.

set "HELPER_BAT=%USERPROFILE%\Desktop\Connect-To-%COMPUTERNAME%.bat"
echo @echo off > "%HELPER_BAT%"
echo title Connecting to \\%COMPUTERNAME%... >> "%HELPER_BAT%"
echo echo ====================================================================== >> "%HELPER_BAT%"
echo echo            CONNECTING TO SHARED PRINTERS ON %COMPUTERNAME% >> "%HELPER_BAT%"
echo echo ====================================================================== >> "%HELPER_BAT%"
echo echo. >> "%HELPER_BAT%"
echo echo [1/2] Pinning %COMPUTERNAME% permanently into 'This PC'... >> "%HELPER_BAT%"
echo powershell -NoProfile -Command "$wsh = New-Object -ComObject WScript.Shell; $scPath = Join-Path ([System.Environment]::GetFolderPath('ApplicationData')) 'Microsoft\Windows\Network Shortcuts\%COMPUTERNAME%.lnk'; $sc = $wsh.CreateShortcut($scPath); $sc.TargetPath = '\\%COMPUTERNAME%'; $sc.Save()" ^>nul 2^>^&1 >> "%HELPER_BAT%"
echo echo. >> "%HELPER_BAT%"
echo echo [2/2] Opening shared folders and printers in File Explorer... >> "%HELPER_BAT%"
echo explorer "\\%COMPUTERNAME%" >> "%HELPER_BAT%"
echo echo. >> "%HELPER_BAT%"
echo echo [+] Connected! %COMPUTERNAME% is now open and permanently pinned in 'This PC'. >> "%HELPER_BAT%"
echo timeout /t 3 ^>nul >> "%HELPER_BAT%"
echo exit >> "%HELPER_BAT%"

set "HELPER_URL=%USERPROFILE%\Desktop\Open-%COMPUTERNAME%-Printers.url"
echo [InternetShortcut] > "%HELPER_URL%"
echo URL=file:///%COMPUTERNAME% >> "%HELPER_URL%"
echo IconIndex=0 >> "%HELPER_URL%"
echo IconFile=shell32.dll >> "%HELPER_URL%"

echo  [+] Created 1-Click Connector on your Desktop:
echo      - File: Connect-To-%COMPUTERNAME%.bat
echo.
echo  ======================================================================
echo  HOW TO SET UP ON ANY CLIENT PC (NON-TECH USERS):
echo  ======================================================================
echo   1. Copy 'Connect-To-%COMPUTERNAME%.bat' to a USB thumb drive.
echo   2. Paste it on the Desktop of the OTHER computer.
echo   3. Double-click the file on that computer.
echo.
echo   WHAT HAPPENS:
echo   - It immediately opens the shared printer and folder.
echo   - It permanently adds '%COMPUTERNAME%' inside 'This PC' (My Computer)
echo     next to Drive C:, so the user never needs to search or browse again!
echo  ======================================================================
echo.
pause
goto MENU


:: ============================================================================
:: OPTION 6: FLUSH STALE SESSIONS AND CACHES
:: ============================================================================
:FLUSH_SESSIONS
cls
echo ======================================================================
echo        FLUSHING STALE NETWORK SESSIONS AND CACHES
echo ======================================================================
echo.
call :FLUSH_CACHES
call :RESTART_SERVICES
echo.
echo [+] Stale network sessions, DNS cache, and NetBIOS tables cleared!
echo.
pause
goto MENU


:: ============================================================================
:: OPTION 7: SHOW ACCOUNT CREDENTIALS AND CONNECTION GUIDE
:: ============================================================================
:SHOW_CREDS
cls
echo ======================================================================
echo            NETWORK CONNECTION AND LOGIN CREDENTIALS HELPER
echo ======================================================================
echo.
echo  [HOST COMPUTER DETAILS]
echo   * Computer Name       : %COMPUTERNAME%

:: Retrieve Active Logged-in User
set "ACTIVE_USER="
for /f "usebackq tokens=*" %%i in (`powershell -NoProfile -Command "(Get-CimInstance Win32_ComputerSystem).UserName" 2^>nul`) do set "ACTIVE_USER=%%i"
if "%ACTIVE_USER%"=="" set "ACTIVE_USER=%COMPUTERNAME%\%USERNAME%"
echo   * Active Logged-in User: %ACTIVE_USER%
echo.
echo  [HOST IP ADDRESSES]
powershell -NoProfile -Command "Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias 'Wi-Fi*','Ethernet*' -ErrorAction SilentlyContinue | Where-Object IPAddress -notmatch '^169\.' | Select-Object InterfaceAlias, IPAddress | Format-Table -AutoSize" 2>nul

echo  [VALID USER ACCOUNTS ON THIS PC]
powershell -NoProfile -Command "Get-LocalUser | Where-Object Enabled -eq $true | Select-Object Name, PrincipalSource, FullName | Format-Table -AutoSize" 2>nul

echo ======================================================================
echo            HOW TO CONNECT FROM ANOTHER PC (CLIENT INSTRUCTIONS)
echo ======================================================================
echo.
echo  Step 1. On the OTHER computer, press [Win + R] on your keyboard.
echo  Step 2. Type either:
echo          \\%COMPUTERNAME%
echo          (or \\^<IP-Address^> from the table above) and press Enter.
echo.
echo  Step 3. When prompted for Username and Password on the other PC:
echo  ----------------------------------------------------------------------
echo   CASE A: IF THIS PC USES A LOCAL ACCOUNT:
echo     * User Name : %ACTIVE_USER%   (or .\%USERNAME%)
echo     * Password  : The local Windows password for that user
echo.
echo   CASE B: IF THIS PC USES A MICROSOFT ACCOUNT (Windows 11 / 10):
echo     On Windows 11, setup often ties logins to a Microsoft email.
echo     Try ANY of these formats in the Username box:
echo     * Option 1 : your_email@outlook.com  (or @hotmail.com / @gmail.com)
echo     * Option 2 : MicrosoftAccount\your_email@outlook.com
echo     * Option 3 : %ACTIVE_USER%
echo     * Password : Your actual MICROSOFT ACCOUNT PASSWORD (NOT your PIN!)
echo  ----------------------------------------------------------------------
echo.
echo  [!] CRITICAL NOTE ON PASSWORDS VS PINS:
echo      Windows Hello 4-digit or 6-digit PINs DO NOT WORK for network sharing!
echo      Windows network authentication requires the REAL account password.
echo.
echo ======================================================================
pause
goto MENU


:: ============================================================================
:: OPTION 8: CHECK CONFIGURATION STATUS
:: ============================================================================
:CHECK_STATUS
cls
echo ======================================================================
echo                     CURRENT CONFIGURATION STATUS
echo ======================================================================
echo.

set "AUTH_MODE=DEFAULT / UNCONFIGURED"
for /f "tokens=3" %%A in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v ForceGuest 2^>nul ^| findstr "ForceGuest"') do (
    if "%%A"=="0x1" set "AUTH_MODE=DISABLED [No password required - Guest mode]"
    if "%%A"=="0x0" set "AUTH_MODE=ENABLED [Username and Password required]"
)
echo  * Password-Protected Sharing : !AUTH_MODE!

set "GUEST_STATUS=Disabled"
net user Guest 2>nul | findstr /i "Account active" | findstr /i "Yes" >nul 2>&1
if !errorlevel! equ 0 set "GUEST_STATUS=Enabled"
echo  * Built-in Guest Account     : !GUEST_STATUS!

set "RPC_FIX=NOT CONFIGURED"
for /f "tokens=3" %%A in ('reg query "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Printers\RPC" /v RpcUseNamedPipeProtocol 2^>nul ^| findstr "RpcUseNamedPipeProtocol"') do (
    if "%%A"=="0x1" set "RPC_FIX=APPLIED [Named Pipes Enabled - 0x00000709 fix]"
)
echo  * RPC Named Pipes [0x00000709]: !RPC_FIX!

set "AUTH_FIX=DEFAULT [Strict]"
for /f "tokens=3" %%A in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Print" /v RpcAuthnLevelPrivacyEnabled 2^>nul ^| findstr "RpcAuthnLevelPrivacyEnabled"') do (
    if "%%A"=="0x0" set "AUTH_FIX=APPLIED [Disabled - 0x0000011b fix]"
)
echo  * RPC Privacy [0x0000011b]    : !AUTH_FIX!

set "SERVER_HIDDEN=DEFAULT [Visible]"
for /f "tokens=3" %%A in ('reg query "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v Hidden 2^>nul ^| findstr "Hidden"') do (
    if "%%A"=="0x0" set "SERVER_HIDDEN=EXPLICITLY VISIBLE [Hidden=0]"
    if "%%A"=="0x1" set "SERVER_HIDDEN=HIDDEN [Hidden=1]"
)
echo  * Network Browser Visibility : !SERVER_HIDDEN!

echo.
echo  [DISCOVERY AND SHARING SERVICES]
powershell -NoProfile -Command "Get-Service -Name FDResPub, lmhosts, spooler, LanmanServer, LanmanWorkstation, SSDPSRV, upnphost -ErrorAction SilentlyContinue | Select-Object Name, Status, StartType | Format-Table -AutoSize" 2>nul

echo ======================================================================
pause
goto MENU


:: ============================================================================
:: REUSABLE SUBROUTINES
:: ============================================================================

:COMMON_FIXES
call :FIX_PROFILE
call :FIX_DISCOVERY_SERVICES
call :FIX_NETBIOS
call :FIX_FIREWALL
call :FIX_USER_RIGHTS
call :FIX_RPC_POLICIES
call :FIX_SPOOLER_PERMISSIONS
exit /b 0


:FIX_PROFILE
echo [1/6] Setting Active Network Profile(s) to Private...
powershell -NoProfile -Command "Get-NetConnectionProfile | Set-NetConnectionProfile -NetworkCategory Private -ErrorAction SilentlyContinue" >nul 2>&1
exit /b 0


:FIX_DISCOVERY_SERVICES
echo [2/6] Enabling and Starting Network Discovery Services...
:: Function Discovery Resource Publication (Publishes PC to WSD network list)
sc config FDResPub start= auto >nul 2>&1
net start FDResPub >nul 2>&1

:: Function Discovery Provider Host
sc config fdPHost start= auto >nul 2>&1
net start fdPHost >nul 2>&1

:: TCP/IP NetBIOS Helper (Crucial for computer name broadcasting)
sc config lmhosts start= auto >nul 2>&1
net start lmhosts >nul 2>&1

:: UPnP Device Host
sc config upnphost start= auto >nul 2>&1
net start upnphost >nul 2>&1

:: SSDP Discovery
sc config SSDPSRV start= auto >nul 2>&1
net start SSDPSRV >nul 2>&1

:: DNS Client / Resolver
sc config Dnscache start= auto >nul 2>&1
net start Dnscache >nul 2>&1

:: SMB Server and Workstation
sc config LanmanServer start= auto >nul 2>&1
net start LanmanServer >nul 2>&1
sc config LanmanWorkstation start= auto >nul 2>&1
net start LanmanWorkstation >nul 2>&1
exit /b 0


:FIX_NETBIOS
echo [3/6] Forcing NetBIOS over TCP/IP and Visibility Settings...
:: Force NetBIOS over TCP/IP (NetbiosOptions = 1) across all active adapters
powershell -NoProfile -Command "Get-CimInstance Win32_NetworkAdapterConfiguration | Where-Object IPEnabled -eq $true | ForEach-Object { Invoke-CimMethod -InputObject $_ -MethodName SetTcpipNetbios -Arguments @{TcpipNetbiosOptions = [uint32]1} -ErrorAction SilentlyContinue }" >nul 2>&1

:: Ensure SMB server is not marked hidden
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v Hidden /t REG_DWORD /d 0 /f >nul 2>&1

:: Enable Multicast Name Resolution (LLMNR) and Hybrid Node Type
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient" /v EnableMulticast /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NetBT\Parameters" /v NodeType /t REG_DWORD /d 8 /f >nul 2>&1
exit /b 0


:FIX_FIREWALL
echo [4/6] Enabling Firewall Rules for Discovery and Sharing...
netsh advfirewall firewall set rule group="File and Printer Sharing" new enable=Yes >nul 2>&1
netsh advfirewall firewall set rule group="Network Discovery" new enable=Yes >nul 2>&1
netsh advfirewall firewall set rule name="File and Printer Sharing (Echo Request - ICMPv4-In)" new enable=Yes >nul 2>&1

:: Explicit Inbound Discovery Port Rules
netsh advfirewall firewall add rule name="WS-Discovery (Inbound UDP 3702)" dir=in action=allow protocol=UDP localport=3702 profile=private,domain >nul 2>&1
netsh advfirewall firewall add rule name="WS-Discovery (Inbound TCP 5357)" dir=in action=allow protocol=TCP localport=5357 profile=private,domain >nul 2>&1
netsh advfirewall firewall add rule name="LLMNR (Inbound UDP 5355)" dir=in action=allow protocol=UDP localport=5355 profile=private,domain >nul 2>&1
netsh advfirewall firewall add rule name="SSDP (Inbound UDP 1900)" dir=in action=allow protocol=UDP localport=1900 profile=private,domain >nul 2>&1
netsh advfirewall firewall add rule name="NetBIOS Name Service (Inbound UDP 137)" dir=in action=allow protocol=UDP localport=137 profile=private,domain >nul 2>&1
netsh advfirewall firewall add rule name="NetBIOS Datagram (Inbound UDP 138)" dir=in action=allow protocol=UDP localport=138 profile=private,domain >nul 2>&1
netsh advfirewall firewall add rule name="NetBIOS Session (Inbound TCP 139)" dir=in action=allow protocol=TCP localport=139 profile=private,domain >nul 2>&1
exit /b 0


:FIX_RPC_POLICIES
echo [5/6] Applying RPC and Print Spooler Policies (Fixes 0x00000709 and 0x0000011b)...
:: Enable RPC over Named Pipes (Fixes 0x00000709)
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\Printers\RPC" /v RpcUseNamedPipeProtocol /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\Printers\RPC" /v RpcProtocols /t REG_DWORD /d 7 /f >nul 2>&1

:: Disable RPC Authentication Level Privacy mismatch (Fixes 0x0000011b)
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Print" /v RpcAuthnLevelPrivacyEnabled /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Print" /v DnsOnWire /t REG_DWORD /d 1 /f >nul 2>&1

:: Allow non-admins to install shared printer drivers
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint" /v RestrictDriverInstallationToAdministrators /t REG_DWORD /d 0 /f >nul 2>&1

:: Disable strict name checking (Fixes connecting by hostname or IP)
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v DisableStrictNameChecking /t REG_DWORD /d 1 /f >nul 2>&1
exit /b 0


:FIX_SPOOLER_PERMISSIONS
echo [6/6] Granting Spooler and Driver Directory Permissions...
icacls "%SystemRoot%\System32\spool\PRINTERS" /grant Everyone:(OI)(CI)F /grant NETWORK:(OI)(CI)F /grant "NT AUTHORITY\ANONYMOUS LOGON":(OI)(CI)F /grant Guest:(OI)(CI)F /T /Q >nul 2>&1
icacls "%SystemRoot%\System32\spool\drivers" /grant Everyone:(OI)(CI)R /grant NETWORK:(OI)(CI)R /grant "NT AUTHORITY\ANONYMOUS LOGON":(OI)(CI)R /grant Guest:(OI)(CI)R /T /Q >nul 2>&1
exit /b 0


:AUTH_DISABLE_PASSWORD
echo [*] Unlocking Built-in Guest Account and Setting Blank Password...
net user Guest /active:yes >nul 2>&1
net user Guest "" >nul 2>&1
net user Guest /expires:never /passwordchg:no /passwordreq:no >nul 2>&1

:: Ensure Guest account is NEVER shown on physical Windows boot/login screen
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList" /v Guest /t REG_DWORD /d 0 /f >nul 2>&1

:: Force incoming logons to authenticate as Guest
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa" /v ForceGuest /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa" /v LimitBlankPasswordUse /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa" /v everyoneincludesanonymous /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa" /v restrictanonymous /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa" /v restrictanonymoussam /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v restrictnullsessaccess /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v NullSessionPipes /t REG_MULTI_SZ /d "spoolss\0netlogon\0lsarpc\0samr\0browser" /f >nul 2>&1
:: Ensure Guest is not denied network logon in Local Security Policy
call :FIX_USER_RIGHTS

:: Client-Side Guest and SMB Configuration
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters" /v AllowInsecureGuestAuth /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters" /v RequireSecuritySignature /t REG_DWORD /d 0 /f >nul 2>&1
powershell -NoProfile -Command "Set-SmbClientConfiguration -EnableInsecureGuestLogons $true -RequireSecuritySignature $false -Force -ErrorAction SilentlyContinue" >nul 2>&1
exit /b 0


:AUTH_ENABLE_PASSWORD
echo [*] Configuring for Password Protection ON (Classic User/Password Authentication)...
net user Guest /active:no >nul 2>&1

:: Force incoming logons to authenticate with their own Windows credentials (Classic mode)
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa" /v ForceGuest /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa" /v LimitBlankPasswordUse /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa" /v everyoneincludesanonymous /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa" /v restrictanonymous /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa" /v restrictanonymoussam /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v restrictnullsessaccess /t REG_DWORD /d 0 /f >nul 2>&1

:: SMB Client settings for authenticated logon
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters" /v AllowInsecureGuestAuth /t REG_DWORD /d 0 /f >nul 2>&1
powershell -NoProfile -Command "Set-SmbClientConfiguration -EnableInsecureGuestLogons $false -Force -ErrorAction SilentlyContinue" >nul 2>&1
exit /b 0


:FLUSH_CACHES
echo [*] Flushing Stale SMB Sessions, NetBIOS Names, and DNS Cache...
net use * /delete /y >nul 2>&1
nbtstat -R >nul 2>&1
nbtstat -RR >nul 2>&1
ipconfig /flushdns >nul 2>&1
exit /b 0


:RESTART_SERVICES
echo [*] Restarting SMB Sharing, Discovery, and Print Spooler Services...
net stop LanmanServer /y >nul 2>&1
net start LanmanServer >nul 2>&1
net stop spooler >nul 2>&1
net start spooler >nul 2>&1
net stop FDResPub >nul 2>&1
net start FDResPub >nul 2>&1
net stop lmhosts >nul 2>&1
net start lmhosts >nul 2>&1
exit /b 0


:FIX_USER_RIGHTS
echo [*] Adjusting User Rights Assignment (Removing network logon denial for Guest)...
set "SECINF=%TEMP%\grant_network_rights_%RANDOM%.inf"
set "SECSDB=%TEMP%\grant_network_rights_%RANDOM%.sdb"
(
echo [Unicode]
echo Unicode=yes
echo [Version]
echo signature="$CHICAGO$"
echo Revision=1
echo [Privilege Rights]
echo SeNetworkLogonRight = *S-1-1-0,*S-1-5-32-544,*S-1-5-32-545,*S-1-5-32-546,*S-1-5-11
echo SeDenyNetworkLogonRight = 
) > "%SECINF%"
secedit /configure /db "%SECSDB%" /cfg "%SECINF%" /areas USER_RIGHTS >nul 2>&1
del "%SECINF%" >nul 2>&1
del "%SECSDB%" >nul 2>&1
gpupdate /force >nul 2>&1
exit /b 0
