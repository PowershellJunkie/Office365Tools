$type = Read-Host "Enter employee type to queue for migration"
#$OU2 = Read-Host "Department number"


$usrArray = @()
#$usrArraydet = Get-ADUser -SearchBase "OU=$type,OU=$OU2,OU=<your OU>,OU=<your OU>,DC=<your DC>,DC=<your DC>" -Filter * | Where {$_.Enabled -eq $True} | Select-Object sAMAccountName,Mail
$usrArraydet = Get-ADUser -Filter {employeetype -eq $type}  -Properties sAMAccountName, Mail | Where {$_.Enabled -eq $True} | Select-Object sAMAccountName,Mail
$usrArray += $usrArraydet 

$usrArray | ForEach-Object{
	
	$user = $_.sAMAccountName
	
	Add-ADGroupMember -Identity "<Office 365 Migration group>" -Members $user
    Add-ADGroupMember -Identity "<Office 365 License group>" -Members $user
    Add-ADGroupMember -Identity "<your ADFS sync group>" -Members $user
    Remove-ADGroupMember -Identity "<any group that might break the migration>" -Members $user -Confirm:$False
	
}

