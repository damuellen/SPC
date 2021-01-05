echo [ Creating dir ]
mkdir C:\Library\Zlib

echo [ Extracting zlib.zip ]
powershell.exe -Command "Expand-Archive -Force 'Zlib.zip' 'C:\Library\Zlib'"
