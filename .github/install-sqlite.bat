echo off
echo [ Creatin dir ]
mkdir C:\sqlite
CD /D C:\sqlite

echo [ Downloading sqlite3.zip ]
powershell.exe -Command "Invoke-WebRequest -OutFile sqlite3.zip https://sqlite.org/2017/sqlite-dll-win64-x64-3160200.zip"

echo [ Extracting sqlite3.zip ]
powershell.exe -Command "Expand-Archive -Force 'C:\sqlite\sqlite3.zip' 'C:\sqlite'"

REM Prepared for GitHub Actions ( @see https://github.com/actions/virtual-environments/blob/master/images/win/Windows2019-Readme.md )
call "C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\VC\Auxiliary\Build\vcvars64.bat"

echo [ Creating sqlite3.lib ]
lib /machine:x64 /def:sqlite3.def /out:sqlite3.lib
set PATH=%PATH%;C:\sqlite
