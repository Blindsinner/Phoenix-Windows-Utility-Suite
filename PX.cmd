@echo off
REM ================================================================
REM                Phoenix Windows Utility Suite Ultimate
REM              (Developed by MD Faysal Mahmud – Revised)
REM
REM  Description: All-in-one toolkit for repairing Windows Update,
REM               optimizing performance, fixing drivers, and
REM               resolving network issues.
REM  Usage: Save as .bat, right-click, "Run as administrator".
REM ================================================================

setlocal ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION

:check_admin
    openfiles >nul 2>&1
    if %errorlevel% neq 0 (
        cls
        echo [ERROR] This script requires administrative privileges.
        echo Please right-click and select “Run as administrator”.
        pause
        exit /b
    )

:menu
    cls
    color 0B
    title Phoenix Utility Suite - Main Menu

    echo ================================================================
    echo                 PHOENIX WINDOWS UTILITY SUITE ULTIMATE
    echo                    (Developed by MD Faysal Mahmud)
    echo ================================================================
    echo.
    echo   [1] Full Windows Update ^& Component Repair
    echo   [2] System Performance ^& Health Optimization
    echo   [3] Driver ^& Hardware Reset
    echo   [4] Complete Network Stack ^& Firewall Reset
    echo   [5] Run Security Scan (Microsoft Defender)
    echo   [6] System Restart
    echo   [7] Limitations ^& Advanced Info
    echo   [0] Exit
    echo.
    echo ================================================================
    set /p "choice=Enter your choice [0-7]: "

    rem Dispatch
    if "%choice%"=="1" goto update_fix
    if "%choice%"=="2" goto performance_fix
    if "%choice%"=="3" goto driver_fix
    if "%choice%"=="4" goto network_fix
    if "%choice%"=="5" goto security_scan
    if "%choice%"=="6" goto restart_pc
    if "%choice%"=="7" goto limitations
    if "%choice%"=="0" exit /b

    rem Invalid selection
    echo.
    echo [ERROR] Invalid choice. Please select a number between 0 and 7.
    pause
    goto menu

:update_fix
    cls
    title Windows Update ^& Component Repair
    echo [*] Performing Full, Combined Update Repair...
    echo.

    echo [1/13] Setting TrustedInstaller to auto-start...
    sc config trustedinstaller start=auto >nul 2>&1
    echo        Done.
    echo.

    echo [2/13] Stopping all update-related services...
    net stop appidsvc >nul 2>&1
    net stop cryptsvc >nul 2>&1
    net stop bits >nul 2>&1
    net stop wuauserv >nul 2>&1
    net stop msiserver >nul 2>&1
    net stop trustedinstaller >nul 2>&1
    echo        Done.
    echo.

    echo [3/13] Renaming cache folders (SoftwareDistribution ^& catroot2)...
    if exist "%SystemRoot%\SoftwareDistribution.old" ( rd /s /q "%SystemRoot%\SoftwareDistribution.old" >nul 2>&1 )
    if exist "%SystemRoot%\System32\catroot2.old" ( rd /s /q "%SystemRoot%\System32\catroot2.old" >nul 2>&1 )
    if exist "%SystemRoot%\SoftwareDistribution" ( Ren %SystemRoot%\SoftwareDistribution SoftwareDistribution.old >nul 2>&1 )
    if exist "%SystemRoot%\System32\catroot2" ( Ren %SystemRoot%\System32\catroot2 catroot2.old >nul 2>&1 )
    echo        Done.
    echo.
    
    echo [4/13] Re-creating cache folders...
    md "%SystemRoot%\SoftwareDistribution" >nul 2>&1
    md "%SystemRoot%\System32\catroot2" >nul 2>&1
    echo        Done.
    echo.

    echo [5/13] Re-registering all necessary DLLs...
    for %%D in (atl.dll urlmon.dll mshtml.dll wuapi.dll wups.dll wuaueng.dll wucltui.dll msxml3.dll) do (
        regsvr32.exe /s %%D >nul 2>&1
    )
    echo        Done.
    echo.

    echo [6/13] Resetting network components (Winsock ^& Proxy)...
    netsh winsock reset >nul 2>&1
    netsh winsock reset proxy >nul 2>&1
    echo        Done.
    echo.

    echo [7/13] Cleaning up PnP drivers...
    rundll32.exe pnpclean.dll,RunDLL_PnpClean /DRIVERS /MAXCLEAN >nul 2>&1
    echo        Done.
    echo.
    
    echo [8/13] Resetting OSUpgrade registry keys...
    reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\OSUpgrade\Rollback" /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\OSUpgrade" /f >nul 2>&1
    echo        Done.
    echo.

    echo [9/13] Running full DISM health suite...
    echo.
    echo        ========================= ATTENTION =========================
    echo        This can take several minutes and may look frozen.
    echo        PLEASE BE PATIENT.
    echo        ===========================================================
    echo.
    dism /Online /Cleanup-image /ScanHealth
    dism /Online /Cleanup-image /RestoreHealth
    dism /Online /Cleanup-image /StartComponentCleanup
    echo        DISM scans complete.
    echo.

    echo [10/13] Running System File Checker (SFC)...
    echo.
    echo        ========================= ATTENTION =========================
    echo        This scan may also take some time. PLEASE BE PATIENT.
    echo        ===========================================================
    echo.
    Sfc /ScanNow
    echo        SFC complete.
    echo.

    echo [11/13] Running deep system cleanup...
    rd /s /q "%SystemRoot%\SoftwareDistribution\DeliveryOptimization" >nul 2>&1
    cleanmgr /verylowdisk >nul 2>&1
    echo        Done.
    echo.

    echo [12/13] Restarting all update-related services...
    net start bits >nul 2>&1
    net start wuauserv >nul 2>&1
    net start cryptsvc >nul 2>&1
    net start msiserver >nul 2>&1
    net start appidsvc >nul 2>&1
    echo        Done.
    echo.

    echo [13/13] Forcing new update detection...
    wuauclt /resetauthorization /detectnow >nul 2>&1
    if exist "%SystemRoot%\System32\UsoClient.exe" (
        UsoClient StartScan >nul 2>&1
    ) else (
        wuauclt /updatenow >nul 2>&1
    )
    echo        Scan initiated.
    echo.

    echo ================================================================
    echo [SUCCESS] Full update repair complete. Please RESTART your PC,
    echo           then check Settings -^> Windows Update.
    echo ================================================================
    pause
    goto menu

:performance_fix
    cls
    title System Performance ^& Health Optimization
    echo [*] Optimizing Performance ^& Health...
    echo.

    echo [1/5] Cleaning temp files...
    
    REM ============================= FIX V2 START ================================
    REM The script runs from the Temp folder, so we must avoid deleting it.
    REM This logic deletes all files and folders from Temp while skipping this
    REM script file (%~f0).

    REM First, delete all sub-folders within the main Temp directory (safe).
    for /d %%D in ("%SystemRoot%\Temp\*") do rd /s /q "%%D" >nul 2>&1

    REM Next, delete all files in the root of Temp, EXCEPT for this script.
    for %%F in ("%SystemRoot%\Temp\*.*") do (
        if /i not "%%~fF"=="%~f0" (
            del /f /q "%%F" >nul 2>&1
        )
    )

    REM Clean Prefetch and User temp folders (these are in different locations
    REM and are safe to clean normally).
    del /q /f /s "%SystemRoot%\Prefetch\*.*" >nul 2>&1
    for /d %%U in ("%SystemDrive%\Users\*") do (
        if exist "%%U\AppData\Local\Temp" (
            del /q /f /s "%%U\AppData\Local\Temp\*.*" >nul 2>&1
        )
    )
    REM ============================== FIX V2 END =================================

    echo        Done.
    echo.

    echo [2/5] Running SFC (System File Checker)...
    echo.
    echo        ========================= ATTENTION =========================
    echo        The system scan is starting. This can take 5-15 minutes
    echo        and may look frozen at first. PLEASE BE PATIENT.
    echo        You will see a percentage count when verification begins.
    echo        ===========================================================
    echo.
    sfc /scannow
    echo        SFC scan complete.
    echo.

    echo [3/5] Running DISM RestoreHealth...
    echo.
    echo        ========================= ATTENTION =========================
    echo        The component store repair is starting. This is often
    echo        slower than SFC. PLEASE BE PATIENT AND DO NOT CLOSE.
    echo        You will see a progress bar when it begins.
    echo        ===========================================================
    echo.
    DISM /Online /Cleanup-Image /RestoreHealth
    echo        DISM scan complete.
    echo.

    echo [4/5] Optimizing disk (Defrag ^& Trim)...
    echo        This will now run. You will see its progress below.
    defrag %SystemDrive%: /O
    echo        Disk optimization complete.
    echo.

    echo [5/5] Launching Disk Cleanup UI...
    echo.
    echo        ========================= ACTION REQUIRED =========================
    echo        A new window will open. Please SELECT the items you want
    echo        to clean, then click OK. The script will wait for you.
    echo        ===================================================================
    echo.
    start "" /wait cleanmgr /sageset:1
    
    echo.
    echo        ========================= PLEASE WAIT =========================
    echo        Disk Cleanup is now running based on your selections.
    echo        This window will wait until it is finished.
    echo        =============================================================
    echo.
    start "" /wait cleanmgr /sagerun:1
    echo        Disk Cleanup finished.
    echo.

    echo ================================================================
    echo [SUCCESS] Performance optimization complete.
    echo ================================================================
    pause
    goto menu

:driver_fix
    cls
    title Driver ^& Hardware Reset
    echo [*] Resetting Drivers ^& Hardware...
    echo.
    echo [WARNING] Screen flicker possible. A reboot is recommended.
    echo.
    set /p "confirm=Proceed with driver reset? (Y/N): "
    if /i not "%confirm%"=="Y" goto menu
    echo.

    echo [1/2] Backing up drivers to %SystemDrive%\PhoenixDriverBackup...
    if not exist "%SystemDrive%\PhoenixDriverBackup" (
      md "%SystemDrive%\PhoenixDriverBackup" >nul 2>&1
    )
    pnputil /export-driver * %SystemDrive%\PhoenixDriverBackup >nul 2>&1
    echo        Backup complete.
    echo.

    echo [2/2] Scanning for hardware changes...
    pnputil /scan-devices
    echo        Scan complete.
    echo.

    echo ================================================================
    echo [SUCCESS] Driver reset complete. Please reboot your PC.
    echo ================================================================
    pause
    goto menu

:network_fix
    cls
    title Network Stack ^& Firewall Reset
    echo [*] Resetting Network Stack ^& Firewall...
    echo.

    echo [1/5] IP/DNS flush ^& renew...
    ipconfig /flushdns   >nul 2>&1
    ipconfig /release    >nul 2>&1
    ipconfig /renew      >nul 2>&1
    ipconfig /registerdns >nul 2>&1
    echo        Done.
    echo.

    echo [2/5] Winsock reset...
    netsh winsock reset   >nul 2>&1
    echo        Done.
    echo.

    echo [3/5] TCP/IP reset...
    netsh int ip reset    >nul 2>&1
    echo        Done.
    echo.

    echo [4/5] Resetting Windows Firewall...
    netsh advfirewall reset>nul 2>&1
    echo        Done.
    echo.

    echo ================================================================
    echo [SUCCESS] Network reset complete. A restart is required.
    echo ================================================================
    pause
    goto menu

:security_scan
    cls
    title Microsoft Defender Security Scan
    echo [*] Running Microsoft Defender Quick Scan...
    echo.

    echo [1/2] Updating definitions...
    "%ProgramFiles%\Windows Defender\MpCmdRun.exe" -SignatureUpdate
    echo.
    echo [2/2] Quick scan in progress...
    "%ProgramFiles%\Windows Defender\MpCmdRun.exe" -Scan -ScanType 1
    echo.

    echo ================================================================
    echo [SUCCESS] Defender scan complete. Review results above.
    echo ================================================================
    pause
    goto menu

:limitations
    cls
    title Limitations and Advanced Information
    echo ================================================================
    echo               What This Script CANNOT Fix
    echo ================================================================
    echo.
    echo This script is powerful, but some issues require manual intervention:
    echo.
    echo  - Hardware driver conflicts that block upgrades.
    echo    (You may need to update or roll back specific drivers manually).
    echo.
    echo  - Group Policy or registry locks in enterprise environments.
    echo.
    echo  - Third-party security/AV interference.
    echo    (Some AV suites can block DISM or the Windows Update agent).
    echo.
    echo  - Severely corrupted Windows installations.
    echo    (An in-place upgrade or full reinstall may be necessary).
    echo.
    echo  - Network infrastructure issues like captive portals or proxies.
    echo    (These require separate network troubleshooting).
    echo.
    echo ================================================================
    pause
    goto menu

:restart_pc
    cls
    title System Restart
    echo This will restart your PC in 15 seconds.
    echo Save all work before proceeding.
    echo.
    set /p "choice=Press Y to restart, any other key to cancel: "
    if /i "%choice%"=="Y" (
        shutdown /r /t 15 /c "Restart initiated by Phoenix Utility Suite." /f
        echo Restart command sent. Exiting...
        timeout /t 5 >nul
        exit /b
    ) else (
        goto menu
    )
