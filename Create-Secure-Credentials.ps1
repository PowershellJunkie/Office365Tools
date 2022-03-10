$input = Get-Credential
$usracct = $input.UserName
$pass = $input.Password
$loc = "\\<server>\<share>\<folder>"
$PassFile = "$loc\$usracct.txt"
$KeyFile = "$loc\Key_$usracct.key"
$Key = New-Object Byte[] 32 
[Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($Key)
$Key | Out-File $KeyFile
$pass | ConvertFrom-SecureString -Key $Key | Out-File $PassFile
