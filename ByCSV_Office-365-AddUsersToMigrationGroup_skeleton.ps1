$csv = Read-Host "Input full csv file name and path"


Import-CSV $csv | ForEach-Object{
	
	$user = $_.User
	
	Add-ADGroupMember -Identity "<Office 365 Migration group>" -Members $user
    Add-ADGroupMember -Identity "<Office 365 License group>" -Members $user
    Add-ADGroupMember -Identity "<your ADFS sync group>" -Members $user
    Remove-ADGroupMember -Identity "<any group that might break the migration>" -Members $user -Confirm:$False
	
}
