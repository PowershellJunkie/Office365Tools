$usracct = (Get-Credential).UserName
$pass = (Get-Credential).Password
$loc1 = Read-Host "Input full path to store created credentials encrpyted file"
$loc2 = Read-Host "Input full path to store created credentials encryption key"
$PassFile = "$loc1\$usracct.txt"
$KeyFile = "$loc2\Key_$usracct.key"
$Key = New-Object Byte[] 32 
[Security.Cryptopgraphy.RNGCryptoServiceProvider]::Create().GetBytes($Key)
$Key | Out-File $KeyFile
$pass | ConvertFrom-SecureString -Key $Key | Out-File $PassFile