@echo off
@call "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvarsall.bat" x64 %*

echo Set environment variables

set SQLITE3=C:\Library\sqlite3

set LIBSQLITE3=C:\Library\sqlite3\sqlite3.lib

SET RUNTIME=C:\Library\Swift-development\bin

SET ICU=C:\Library\icu-67\usr\bin

echo Build release mode

swift build -c release

echo Strip debug info

llvm-strip -S --keep-file-symbols .build\x86_64-unknown-windows-msvc\release\SolarPerformanceCalc.exe
llvm-strip -S --keep-file-symbols .build\x86_64-unknown-windows-msvc\release\SolarFieldCalc.exe

echo Create program folder

MKDIR %LOCALAPPDATA%\SPC 2>NUL

echo Copy executable to program folder

COPY %cd%\.build\x86_64-unknown-windows-msvc\release\SolarPerformanceCalc.exe %LOCALAPPDATA%\SPC\SPC.exe >NUL
COPY %cd%\.build\x86_64-unknown-windows-msvc\release\SolarFieldCalc.exe %LOCALAPPDATA%\SPC\SFC.exe >NUL

echo Add path environment variable

SET PATH=%PATH%;%ICU%;%RUNTIME%;%SQLITE3%;%LOCALAPPDATA%\SPC

PAUSE

CLS

%comspec% /K chcp 65001
