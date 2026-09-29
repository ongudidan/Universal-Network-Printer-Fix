# 🖨️ Universal Windows Network Printer & Sharing Fix

An all-in-one automation and repair utility for Windows 10, Windows 11, and Windows Server that fixes peer-to-peer network printer sharing, file sharing, network discovery, and authentication issues.

---

## 🚀 Key Problems Resolved

* **Error `0x0000011b`**: Fixes RPC authentication-level privacy mismatch caused by Windows security updates.
* **Error `0x00000709`**: Restores RPC over Named Pipes communication required on Windows 11 22H2+.
* **"Enter network credentials" Loop**: Resolves persistent password prompt loops caused by disabled `Guest` accounts, blank password network blocks (`LimitBlankPasswordUse`), and client-side insecure guest logon restrictions.
* **Hidden from Network Folder**: Fixes PCs not appearing in File Explorer's **Network** folder by configuring WS-Discovery (`FDResPub`), forcing NetBIOS over TCP/IP, and opening inbound discovery firewall ports.
* **Windows 11 Microsoft Account & PIN Confusion**: Provides clear credentials guidance for machines set up with Microsoft Accounts and reminds users why Windows Hello PINs do not work over SMB network sharing.
* **Access Denied on Spooler**: Fixes print spooler buffer permission errors on `%SystemRoot%\System32\spool\PRINTERS`.

---

## 📋 Menu Options Overview

```text
======================================================================
         UNIVERSAL WINDOWS NETWORK PRINTER AND SHARING FIX
======================================================================

  [1] Full Fix - Password Protection OFF (No Login Required)
      * Ideal for Home / SOHO workgroups.
      * Unlocks Guest, clears blank password block, fixes client guest block.
      * Full Network Visibility: WSD, NetBIOS, SSDP, and Firewall enabled.

  [2] Full Fix - Password Protection ON (Username and Password Required)
      * Ideal for Office / Secure environments.
      * Prompts connecting users for a valid Windows account and password.
      * Full Network Visibility: WSD, NetBIOS, SSDP, and Firewall enabled.

  [3] Quick Toggle Authentication and Guest Account (ON / OFF / Test)
      * Switch password mode or toggle Guest account to test behavior.

  [4] Repair Network Discovery and PC Visibility in File Explorer
      * Fixes "PC not showing in Network folder on other PCs".
      * Forces NetBIOS over TCP/IP, WSD broadcast, and discovery services.

  [5] Create 1-Click Connector (Pins to 'This PC' for Non-Tech Users)
      * Generates a double-click helper on Desktop for remote PCs.
      * Permanently pins this printer host directly into 'This PC'.

  [6] Flush Stale Network Sessions and DNS/NetBIOS Cache
      * Fixes persistent prompt loops caused by old cached logins.

  [7] Show Account Credentials and Connection Guide (For Other PCs)
      * View exact Username/Password formats to use on remote PCs.
      * Resolves Windows 11 Microsoft Account and PIN login confusion.

  [8] Check Current Configuration Status

  [9] Exit
======================================================================
```

---

## 🛠️ How to Use

### Step 1: Run the Script as Administrator
1. Right-click [`Universal-Network-Printer-Fix.bat`](file:///c:/Users/Dan%20Ong%27udi/Projects/Universal-Network-Printer-Fix/Universal-Network-Printer-Fix.bat).
2. Click **Run as administrator**.

---

### Step 2: Choose Your Sharing Mode

#### Option 1: No Password Required (Frictionless / Home / SOHO)
* Select **`[1] Full Fix - Password Protection OFF`**.
* The script automatically:
  - Sets network profile to **Private**.
  - Activates the built-in `Guest` account with a blank password.
  - Removes the "Blank Password over Network" block (`LimitBlankPasswordUse = 0`).
  - Hides the `Guest` account from the physical Windows boot/login screen.
  - Fixes client-side insecure guest restrictions (`AllowInsecureGuestAuth = 1`).
  - Applies PrintNightmare and RPC named pipe fixes (`0x0000011b` / `0x00000709`).
  - Opens firewall ports and restarts spooler and sharing services.
* **Result**: Other PCs can access shared printers and folders instantly without any login prompts.

---

#### Option 2: Password Required (Secure / Office Environments)
* Select **`[2] Full Fix - Password Protection ON`**.
* The script configures classic user-based authentication, applies all RPC and firewall fixes, and then displays the **Login Credentials Guide**.
* **Result**: Users connecting from other computers will be prompted for a valid Windows username and password.

---

### Step 3: Setting Up Non-Tech Users (Option 5)

If connecting users struggle with browsing the Network folder or typing commands:

1. On the host PC, select **`[5] Create 1-Click Connector`**.
2. It generates a small file on your Desktop: `Connect-To-<COMPUTERNAME>.bat`.
3. Copy that file onto the other computer's Desktop (via a USB drive or network share).
4. **The non-tech user double-clicks the file once**:
   - It immediately opens the shared printers and folders.
   - It **permanently pins this host computer into "This PC" (My Computer)** alongside Drive C:.
   - They never need to browse the network or type IP addresses again!

---

## 🔑 Login Guide for Other PCs (When Password Protection is ON)

When prompted for **Network Credentials** on another computer:

### If the Host PC Uses a Local Windows Account:
* **Username**: `COMPUTERNAME\Username` *(e.g., `FORTUNEDEVS\Dan Ong'udi` or `.\Dan Ong'udi`)*
* **Password**: The user's actual Windows login password.

### If the Host PC Was Set Up With a Microsoft Account (Windows 11):
* **Username Format 1**: `your_email@outlook.com` *(or `@hotmail.com`, `@gmail.com`)*
* **Username Format 2**: `MicrosoftAccount\your_email@outlook.com`
* **Username Format 3**: `COMPUTERNAME\Username`
* **Password**: Your actual **Microsoft Account Password**.

> [!IMPORTANT]
> **Windows Hello PINs (4 or 6-digit quick PINs) and Fingerprint/Face Recognition DO NOT work for network sharing authentication.**
> You must enter the real account password.

---

## 📖 Manual Configuration Guide (Without the Script)

If you prefer to configure these settings manually or want to understand what commands are being executed under the hood:

### 1. Turn ON the `Guest` Account with a Blank Password
Open **Command Prompt as Administrator** and run:
```cmd
:: 1. Enable the built-in Guest account
net user Guest /active:yes

:: 2. Set the password to blank (empty)
net user Guest ""

:: 3. Ensure the password never expires and is not required
net user Guest /passwordreq:no /expires:never

:: 4. Allow blank passwords over the local network (CRITICAL!)
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v LimitBlankPasswordUse /t REG_DWORD /d 0 /f

:: 5. Keep Guest hidden from the physical Windows boot/login screen
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList" /v Guest /t REG_DWORD /d 0 /f

:: 6. Restart the sharing service
net stop LanmanServer /y && net start LanmanServer
```

---

### 2. Manually Turn Password-Protected Sharing OFF (Guest Mode)
```cmd
:: Force incoming connections to authenticate automatically as Guest
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v ForceGuest /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v LimitBlankPasswordUse /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v everyoneincludesanonymous /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v restrictanonymous /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v restrictnullsessaccess /t REG_DWORD /d 0 /f

:: Client-side: Allow connection to insecure guest shares
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters" /v AllowInsecureGuestAuth /t REG_DWORD /d 1 /f
powershell -NoProfile -Command "Set-SmbClientConfiguration -EnableInsecureGuestLogons $true -Force"
```

---

### 3. Manually Turn Password-Protected Sharing ON (Classic Mode)
```cmd
:: Force incoming connections to authenticate with their own Windows credentials
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v ForceGuest /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v LimitBlankPasswordUse /t REG_DWORD /d 1 /f
net user Guest /active:no
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters" /v AllowInsecureGuestAuth /t REG_DWORD /d 0 /f
```

---

### 4. Manually Fix RPC Print Errors (`0x0000011b` & `0x00000709`)
```cmd
:: Enable RPC over Named Pipes (Fixes 0x00000709 on Windows 11)
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Printers\RPC" /v RpcUseNamedPipeProtocol /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Printers\RPC" /v RpcProtocols /t REG_DWORD /d 7 /f

:: Disable strict RPC Authentication Level Privacy (Fixes 0x0000011b)
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Print" /v RpcAuthnLevelPrivacyEnabled /t REG_DWORD /d 0 /f

:: Allow non-administrators to install Point-and-Print drivers
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Printers\PointAndPrint" /v RestrictDriverInstallationToAdministrators /t REG_DWORD /d 0 /f
```

---

### 5. Manually Fix Network Discovery in File Explorer
```cmd
:: Set discovery services to Automatic and start them
sc config FDResPub start= auto && net start FDResPub
sc config lmhosts start= auto && net start lmhosts
sc config SSDPSRV start= auto && net start SSDPSRV
sc config upnphost start= auto && net start upnphost

:: Enable discovery and sharing firewall rules
netsh advfirewall firewall set rule group="File and Printer Sharing" new enable=Yes
netsh advfirewall firewall set rule group="Network Discovery" new enable=Yes
```

---

## 🔍 Troubleshooting Matrix

| Issue / Symptom | Recommended Action |
| :--- | :--- |
| **PC not showing in "Network" folder on other computers** | 1. Run Option `[4]` on both the host and client PC.<br>2. Or use Option `[5]` to bypass the Network folder completely. |
| **Turned off password sharing manually, but still asked for password** | Run Option `[1]`. Windows leaves the `Guest` account disabled and blank passwords blocked by default; Option `[1]` unlocks both. |
| **Getting stuck in a password prompt loop with cached bad credentials** | Run Option `[6]` on the client PC to flush stale SMB sessions and NetBIOS cache. |
| **Printer gives error `0x0000011b` or `0x00000709`** | Run Option `[1]` or `[2]`. Both options automatically apply RPC Named Pipe and privacy level patches. |
| **Standard users cannot install shared printer drivers** | The script automatically configures Point-and-Print policy (`RestrictDriverInstallationToAdministrators = 0`). |

---

## 🔒 Security & Privacy Information

* **Physical Lock Screen Safeguard**: When the `Guest` account is activated for network sharing, the script writes a registry rule (`SpecialAccounts\UserList\Guest = 0`) to ensure the `Guest` account is **never** displayed on the physical computer boot/login screen.
* **Scope**: Changes apply only to **Private** network profiles. When connected to Public Wi-Fi (e.g., coffee shops or airports), Windows Defender Firewall keeps sharing and discovery strictly blocked.

---

## 📄 License
Open source utility for IT administrators, technician toolkits, and home office setups.
