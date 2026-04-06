@echo off
setlocal ENABLEEXTENSIONS

REM =========================
REM Usage:
REM   build.bat [preset] [config] [generator]
REM =========================

set "PRESET=%~1"
set "CONFIG=%~2"
set "GENERATOR=%~3"

if "%CONFIG%"=="" set "CONFIG=Release"

REM -------------------------
REM Try preset if provided
REM -------------------------
if not "%PRESET%"=="" (
    echo [Windows] Building with CMake preset "%PRESET%"...
    cmake --build --preset "%PRESET%"
    if not errorlevel 1 exit /b %ERRORLEVEL%
    echo [Windows] Preset failed, falling back...
)

REM -------------------------
REM Auto-detect generator if not provided
REM -------------------------
if "%GENERATOR%"=="" (
    where ninja >nul 2>nul
    if not errorlevel 1 (
        set "GENERATOR=Ninja"
    ) else (
        where cl >nul 2>nul
        if not errorlevel 1 (
            set "GENERATOR=Visual Studio 17 2022"
        ) else (
            where gcc >nul 2>nul
            if not errorlevel 1 (
                set "GENERATOR=MinGW Makefiles"
            ) else (
                echo [Windows] No suitable compiler found.
                goto ERROR
            )
        )
    )
)

echo [Windows] Using generator: %GENERATOR%

REM -------------------------
REM Configure
REM -------------------------
if not exist build mkdir build

cmake -S . -B build -G "%GENERATOR%" -DCMAKE_BUILD_TYPE=%CONFIG%
if errorlevel 1 goto ERROR

REM -------------------------
REM Build
REM -------------------------
cmake --build build --config %CONFIG%
if errorlevel 1 goto ERROR

exit /b %ERRORLEVEL%

:ERROR
echo [Windows] Build failed.
exit /b 1