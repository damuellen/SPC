echo off
echo [ Creating dir ]
mkdir C:\Library\Zlib
CD /D C:\Library\Zlib

echo [ Extracting zlib.zip ]
powershell.exe -Command "Expand-Archive -Force 'D:\a\SPC\SPC\Zlib.zip' 'C:\Library\Zlib'"
