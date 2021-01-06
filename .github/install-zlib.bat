echo [ Creating dir ]
mkdir C:\Library\Zlib

echo [ Extracting zlib.zip ]
powershell.exe -Command "Expand-Archive -Force 'C:\temp\Zlib.zip' 'C:\Library\Zlib'"
