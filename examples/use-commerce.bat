@echo off
setlocal

REM Check if argument is provided
if "%~1"=="" (
    echo Usage: %~nx0 ^<path-to-commerce^>
    exit /b 1
)

REM Resolve script directory
set "SCRIPT_DIR=%~dp0"
set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"  REM Remove trailing backslash

REM Resolve full path to commerce directory
pushd "%~1" >nul 2>&1
if errorlevel 1 (
    echo Error: Directory "%~1" does not exist
    exit /b 1
)
set "COMMERCE_DIR=%cd%"
popd

REM Change to script directory
cd /d "%SCRIPT_DIR%"

REM Check if index.php exists in commerce dir
if not exist "%COMMERCE_DIR%\index.php" (
    echo Make sure you have chosen a valid commerce directory.
    exit /b 1
)

REM Create symlink to commerce dir as www
if exist www (
    rmdir www
)
mklink /D www "%COMMERCE_DIR%"

REM Create assets symlink if lc/fwk exists
if exist "%SCRIPT_DIR%\lc\fwk" (
    if exist www\assets\core (
        rmdir www\assets\core
    )
    mklink /D www\assets\core \local\lc\fwk\assets
)

endlocal