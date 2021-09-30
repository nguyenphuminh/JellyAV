@echo off
setlocal EnableDelayedExpansion

:menu
color 1f
cls
echo Jelly Antivirus Version 0.1.0 BETA
echo.
echo Options:
echo.
echo 1. Full scan.              (BETA)
echo 2. Scan a directory.      (STABLE)
echo 3. Scan a file.           (STABLE)
echo 4. Utilities.             (STABLE)
echo.
choice /c:1234 /n
if errorlevel 4 goto utils
if errorlevel 3 goto file_scan
if errorlevel 2 goto dir_scan
if errorlevel 1 goto full_scan
goto menu

:full_scan
cls
set hash=
set target=
for /f "tokens=*" %%i in ('fsutil fsinfo drives') do set drives=%%i
set drives=!drives:Drives: =!
set old_drive=%cd:~0,2%
set old_cd=%cd%
for %%a in (!drives!) do (
	set drive=%%a
	!drive:\=!
	cd /
	for /r "!drive!" %%j in (*.*) do (
		for /f "tokens=2" %%i in ('powershell Get-FileHash "%%j"') do set hash=%%i
		for /f %%i in (Jelly_Database.txt) do (
			if "!hash!" == "%%i" (
				del /q %%j
				echo "%%j" removed^^!
			)
		)
	)
)
!old_drive!
cd !old_cd!
pause >nul
goto menu

:dir_scan
cls
set hash=
set target=
set /p target=Drop the folder or enter the directory here (Leave blank to go back^): 
if "%target%" == "" goto menu
echo.
if exist "%target%" (
	for /r "%target%\" %%j in (*.*) do (
		for /f "tokens=2" %%i in ('powershell Get-FileHash "%%j"') do set hash=%%i
		for /f %%i in (Jelly_Database.txt) do (
			if "!hash!" == "%%i" (
				del /q %%j
				echo "%%j" removed^^!
			)
		)
	)
)
pause >nul
goto menu

:file_scan
cls
set hash=
set target=
set /p target=Drop the file or enter the file's path here (Leave blank to go back^): 
if "%target%" == "" goto menu
echo.
if exist "%target%" (
	for /f "tokens=2" %%i in ('powershell Get-FileHash "%target%"') do set hash=%%i
	for /f %%i in (Jelly_Database.txt) do (
		if "!hash!" == "%%i" (
			color 4f
			echo "%target%" is dangerous, delete it? (Y/N^)
			echo.
			choice /c:yn /n >nul
			if errorlevel 2 goto menu
			if errorlevel 1 (
				del /q %target%
				color 1f
				echo Dangerous file removed^^!
				pause >nul
				goto menu
			)
		)
	)
)
echo "%target%" is safe^^!
pause >nul
goto menu

:utils
color 1f
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
		del /q "!util_dir:"=!\*.lnk"
		attrib -s -r -h "!util_dir:"=!\*.*" /s /d /l
		pause
	) 
)
goto utils
