@echo off

SET SQLITE=C:\Library\sqlite3

SET RUNTIME=C:\Library\Swift-development\bin

SET ICU=C:\Library\icu-67\usr\bin

@call "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvarsall.bat" x64 %*

swift build -c release

MKDIR %LOCALAPPDATA%\SPC

COPY %cd%\.build\x86_64-unknown-windows-msvc\release\SolarPerformanceCalc.exe %LOCALAPPDATA%\SPC\SPC.exe

COPY %cd%\.build\x86_64-unknown-windows-msvc\release\SwiftToolsSupport.dll %LOCALAPPDATA%\SPC

COPY %SQLITE%\sqlite3.dll %LOCALAPPDATA%\SPC

COPY %RUNTIME%\*.dll %LOCALAPPDATA%\SPC

COPY %ICU%\*.dll %LOCALAPPDATA%\SPC

SET PATH=%PATH%;%LOCALAPPDATA%\SPC

CLS

%comspec% /K chcp 65001
