@echo off
setlocal EnableDelayedExpansion


:menu

:: Resets color
color 0f
cls

echo Jelly Antivirus Version 0.1.1 BETA
echo.
echo Options:
echo.
echo 1. Scan a directory.      (STABLE)
echo 2. Scan a file.           (STABLE)
echo 3. Utilities.             (STABLE)
echo.
choice /c:123 /n
if errorlevel 3 goto utils
if errorlevel 2 goto file_scan
if errorlevel 1 goto dir_scan
goto menu


:dir_scan

:: dir_scan is the "Scan a directory" feature.
:: It works by looping through files in a directory, then compare their file hash with the ones in the virus database.

cls

:: Resets target to be scanned.
set hash=
set target=

set /p target=Drop the folder or enter the directory here (Leave blank to go back^): 

:: Goes back to menu if no path was provided
if "%target%" == "" goto menu

echo.

:: Start scanning if provided path exists
if exist "%target%" (
	:: Iterates over files in provided directory
	for /r "%target%\" %%j in (*.*) do (
		:: Get file hash using certutil
		for /f "delims=" %%i in ('CertUtil -hashfile "%%j" SHA256 ^| find /v "CertUtil" ^| find /v ":"') do set hash=%%i
		:: Compare hash
		for /f %%i in (database.txt) do (
			if "!hash!" == "%%i" (
				del /q "%%j"
				echo "%%j" removed^^!
			)
		)
	)
)

echo Scan finished^^! Press any key to continue...

pause >nul
goto menu


:file_scan

:: file_scan is the "Scan a file" feature.
:: It is the same as "dir_scan" but with a single file only.

cls

:: Resets target to be scanned.
set hash=
set target=

set /p target=Drop the file or enter the file's path here (Leave blank to go back^): 

:: Goes back to menu if no path was provided
if "%target%" == "" goto menu

echo.

:: Start scanning if provided path exists
if exist "%target%" (
	:: Get file hash using certutil
	for /f "delims=" %%i in ('CertUtil -hashfile "%target%" SHA256 ^| find /v "CertUtil" ^| find /v ":"') do set hash=%%i
	:: Compare hash
	for /f %%i in (database.txt) do (
		if "!hash!" == "%%i" (
			:: Change color to red if the file is a virus
			color 4f

			:: Prompt for deletion
			echo "%target%" is dangerous, delete it? (Y/N^)
			echo.

			choice /c:yn /n >nul
			if errorlevel 2 goto menu
			if errorlevel 1 (
				del /q "%target%"
				color 0f
				echo Dangerous file removed^^! Press any key to continue...

				pause >nul
				goto menu
			)
		)
	)
)

:: Prompt if file is safe
echo "%target%" is safe^^!

pause >nul
goto menu


:utils

:: utils is other utilities of JellyAV

:: Resets color
color 0f
cls

echo Jelly Antivirus Version 0.1.0 BETA
echo.
echo Utilities - Options:
echo.
echo 1. Fix shortcut viruses.
echo 2. Go back.
echo.

choice /c:12 /n
if errorlevel 2 goto menu
if errorlevel 1 (
	cls
	set /p util_dir=Enter directory or drop in the folder: 
	if exist "!util_dir!" (
		attrib -s -r -h "!util_dir:"=!\*.*" /s /d /l
		pause
	) 
)

goto utils
