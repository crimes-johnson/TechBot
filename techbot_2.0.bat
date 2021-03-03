@echo off
REM If Else to check for windows based system
if %os%==Windows_NT goto WINNT
goto NOCON

:WINNT

REM Startup fluff
echo ------------------Welcome to TechBot version 2.0-------------------
echo For logging purposes, the timezone will be set as Central US Time. 
echo Before continuing, please connect this machine to the open internet. 
pause
tzutil /s "Central Standard Time"

REM Setting timestamp of scan
FOR /F "tokens=2 delims='='" %%A in ('wmic OS Get localdatetime /value') do SET dt=%%A
set "YYYY=%dt:~0,4%" 
set "MM=%dt:~4,2%" 
set "DD=%dt:~6,2%"
set "HH=%dt:~8,2%" 
set "Min=%dt:~10,2%" 
set "Sec=%dt:~12,2%"
set "fullstamp=%YYYY%-%MM%-%DD% / %HH%:%Min%:%Sec%"
echo +---------------------------------------------+
echo The current log time is %fullstamp%
echo +---------------------------------------------+

REM adding Wi-Fi profile, deprecated
REM netsh wlan add profile filename="D:\Wi-Fi-bstock.xml" 
REM Change the SSID to test other WLANs
REM netsh wlan connect ssid= name=

echo TechBot will now test this machine's networking.    
echo If there is no WLAN service running, then either the service failed to start or WiFi is not available on this machine. 
timeout /t 60
echo Testing connection to Google DNS...
ping 8.8.8.8
echo -----------------------------------------------------------------------------------------------------------------------
echo Testing complete. If you can't reach the open internet, please close this script and fix the issue before proceeding. 
echo Let's collect this machine's specifications now. 
timeout /t 60

REM setting variables for each spec to check
setlocal ENABLEDELAYEDEXPANSION
set system=
set manufacturer=
set model=
set serialnumber=
set osname=
set cpuname=
set "volume=C:\"
set totalMem=
set wifidev=
set gpuname=

REM Get Computer Name
FOR /F "tokens=2 delims='='" %%A in ('wmic OS Get csname /value') do SET system=%%A

REM Get Computer Manufacturer
FOR /F "tokens=2 delims='='" %%A in ('wmic ComputerSystem Get Manufacturer /value') do SET manufacturer=%%A

REM Get Computer Model
FOR /F "tokens=2 delims='='" %%A in ('wmic ComputerSystem Get Model /value') do SET model=%%A

REM Get Computer Serial Number
FOR /F "tokens=2 delims='='" %%A in ('wmic Bios Get SerialNumber /value') do SET serialnumber=%%A

REM Get Computer OS
FOR /F "tokens=2 delims='='" %%A in ('wmic os get Name /value') do SET osname=%%A
FOR /F "tokens=1 delims='|'" %%A in ("%osname%") do SET osname=%%A

REM Get CPU Name
FOR /F "tokens=2 delims='='" %%A in ('wmic CPU get NAME /value') do SET cpuname=%%A

REM Get RAM size
FOR /F "tokens=4" %%a in ('systeminfo ^| findstr Physical') do if defined totalMem (set availableMem=%%a) else (set totalMem=%%a)
set totalMem=%totalMem:,=%

REM Get C:\ total space, available drive space is commented out because we probably don't need it
FOR /f "tokens=1*delims=:" %%i in ('fsutil volume diskfree %volume%') do (
    SET "diskfree=!disktotal!"
    SET "disktotal=!diskavail!"
    SET "diskavail=%%j"
)
FOR /f "tokens=1,2" %%i in ("%disktotal% %diskavail%") do SET "disktotal=%%i"& SET "diskavail=%%j"

REM Windows Activation Status
Set "WinVerAct="
FOR /F "tokens=*" %%W in ('cscript /Nologo "C:\Windows\System32\slmgr.vbs" /xpr') Do Set "WinVerAct=!WinVerAct! %%W"
if Not defined WinVerAct (
	Echo:No response from slmgr.vbs
    Exit /B 1
)

REM Get wireless device name
FOR /F "tokens=2 delims=:" %%A in ('netsh wlan show interfaces ^| findstr Description') do SET wifidev=%%A

REM GPU information
FOR /F "tokens=2-4 delims='='" %%A in ('wmic path win32_VideoController get name /value') do SET gpuname=%%A

REM Show in cmd window the specs that were collected
echo +--------------------------- Scan Details ---------------------------+  
echo System Name: %system%
echo Manufacturer: %manufacturer%
echo Model: %model%
echo Serial Number: %serialnumber%
echo Operating System: %osname%
echo %WinVerAct:~1%
echo Computer Processor: %cpuname%
echo Drive Space: %disktotal:~0,-9% GB
echo RAM: %totalMem% MB
echo GPU: %gpuname%
echo Wireless: %wifidev%
echo LogFile: %computername%.txt
echo +--------------------------------------------------------------------+

REM Write to output file
SET file="%~dp0%computername%.txt"
echo //////////////////////////// Scan Details //////////////////////////// >> %file%
echo %fullstamp% >> %file%
echo Details For: %system% >> %file%
echo Manufacturer: %manufacturer% >> %file%
echo Model: %model% >> %file%
echo Serial Number: %serialnumber% >> %file%
echo Operating System: %osname% >> %file%
Echo %WinVerAct:~1% >> %file%
echo Computer Processor: %cpuname% >> %file%
echo Drive Space: %disktotal:~0,-9% GB >> %file%
echo RAM: %totalMem% MB >> %file%
echo GPU: %gpuname% >> %file%
echo Wireless: %wifidev% >> %file%
echo +-------------------------------------------------------------------+ >> %file%

REM Component tests/fluff
echo Would you like to proceed with the component tests? If not, please exit the script now. 
echo Continuing the script will open several web pages and the Windows Camera App. 

timeout /t 60

start "" https://www.keyboardtester.com/tester.html
start "" https://mictests.com/check
start "" https://www.youtube.com/watch?v=f02mOEt11OQ
start microsoft.windows.camera:
REM control mmsys.cpl sounds #Deprecated sound check

pause

REM Performance monitor section for diags (deprecated)
REM echo --------------------------------------------------------------------------------------------------
REM echo TechBot will now open Performance Monitor. Please start a new System Diagnostic Report.
REM echo Data Collector Sets > System > Right Click "System Diagnostics", then "Start". 
REM echo Now select the new report under Reports > System > System Diagnostics.
REM echo It will take 60 seconds to complete. Please close Performance Monitor after reviewing the report.
REM echo --------------------------------------------------------------------------------------------------

REM Wait 30 seconds before continuing
REM timeout /t 30

REM perfmon

echo //////////////////////////////////////////////////////////////////////////////////////////
echo Components test complete. 
echo Would you like to reset Windows? If not, please exit the script. 
echo //////////////////////////////////////////////////////////////////////////////////////////
pause

REM Windows reset fluff and commands
echo TechBot will now begin the Windows Reset process in 60 seconds. You can cancel during the reset setup phase only. 
echo WARNING: Resetting Windows will set the machine back to default settings, thus removing all files and configurations. 
echo If you have installed any device drivers that are not stock, they will be removed!
timeout /t 60
systemreset

REM Script end
goto END

REM Script end if the system isn't Windows based
:NOCON
echo Error...Invalid Operating System...
echo Error...No actions were made...
goto END

:END