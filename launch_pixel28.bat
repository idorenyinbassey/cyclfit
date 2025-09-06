@echo off
title Pixel_API_28 Flutter Launcher
echo ==========================================
echo  Keeping only Pixel_API_28 AVD
echo ==========================================

REM Paths
set SDK_EMULATOR=C:\Users\ADMIN\AppData\Local\Android\Sdk\emulator\emulator.exe
set SDK_AVDMANAGER=C:\Users\ADMIN\AppData\Local\Android\Sdk\cmdline-tools\latest\bin\avdmanager.bat
set ADB=C:\Users\ADMIN\AppData\Local\Android\Sdk\platform-tools\adb.exe
set KEEP_AVD=Pixel_API_28

echo.
echo Deleting other AVDs...
for /f "delims=" %%a in ('"%SDK_EMULATOR%" -list-avds') do (
    if NOT "%%a"=="%KEEP_AVD%" (
        echo Deleting AVD: %%a
        "%SDK_AVDMANAGER%" delete avd -n %%a
    )
)

echo.
echo Starting emulator: %KEEP_AVD%
start "" "%SDK_EMULATOR%" -avd %KEEP_AVD% -no-snapshot -no-boot-anim -gpu swiftshader_indirect

echo.
echo Waiting for emulator to boot...
:waitloop
%ADB% wait-for-device
for /f "tokens=*" %%b in ('%ADB% shell getprop sys.boot_completed 2^>nul') do set booted=%%b
if NOT "%booted%"=="1" (
    echo Still booting...
    timeout /t 5 >nul
    goto waitloop
)

echo Emulator booted successfully!
echo.

cd /d C:\Users\ADMIN\Desktop\cyclfit_app
echo Running Flutter app...
flutter run

