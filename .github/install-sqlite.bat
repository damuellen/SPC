echo off
echo [ Creating dir ]
mkdir C:\Library\sqlite3
CD /D C:\Library\sqlite3

echo [ Downloading sqlite3.zip ]
powershell.exe -Command "Invoke-WebRequest -OutFile sqlite3.zip https://www.sqlite.org/2020/sqlite-dll-win64-x64-3330000.zip"
echo [ Extracting sqlite3.zip ]
powershell.exe -Command "Expand-Archive -Force 'C:\Library\sqlite3\sqlite3.zip' 'C:\Library\sqlite3'"
powershell.exe -Command "Remove-Item 'C:\Library\sqlite3\*.zip'"
REM Prepared for GitHub Actions ( @see https://github.com/actions/virtual-environments/blob/master/images/win/Windows2019-Readme.md )
call "C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\VC\Auxiliary\Build\vcvars64.bat"

echo [ Creating sqlite3.lib ]
lib /machine:x64 /def:sqlite3.def /out:sqlite3.lib
set LIBSQLITE3=C:\Library\sqlite3\sqlite3.lib
