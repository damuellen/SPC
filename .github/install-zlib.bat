echo off
echo [ Creating dir ]
mkdir C:\Library\Zlib
CD /D C:\Library\Zlib

echo [ Downloading Zlib.zip ]
powershell.exe -Command "Invoke-WebRequest -OutFile zlib.zip http://zlib.net/zlib128-dll.zip"
echo [ Extracting zlib.zip ]
powershell.exe -Command "Expand-Archive -Force 'C:\Library\Zlib\zlib.zip' 'C:\Library\Zlib'"
powershell.exe -Command "Remove-Item 'C:\Library\Zlib\*.zip'"
REM Prepared for GitHub Actions ( @see https://github.com/actions/virtual-environments/blob/master/images/win/Windows2019-Readme.md )
call "C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\VC\Auxiliary\Build\vcvars64.bat"

echo [ Creating Zlib.lib ]
lib /machine:x64 /def:zlib.def /out:Zlib.lib
