<#
	This script was written specifically to be used in conjuction with my Office 365 migration tool kit scripts for migrating users off of Exchange
	This script requires that you have setup a Security Group with which you plan to migrate users; migrated user stay in this group and are identified by the 'msExchRemoteRecipientType' attribute in other scripts and by Office 365
	Using this particular script, the employees are added to the migration group by their job code/employee type. The migration scripts handle the rest
	This can be retooled for other purposes, obviously
#>

# Start by collecting the desired information; the group you want to add users to and the employee type of user you want to add

$emptype = Read-Host "Input employee type here"
$group = Read-Host "Enter the desired group here"

# Create the array and then populate it with the users based on their employee type. As it stands, this will only get enabled accounts. It will not touch disabled accounts, including templates.

$usrArray = @()
$usrArraydet = Get-ADUser -Filter {employeetype -eq $emptype} | Where {$_.Enabled -eq $true} | Select-Object sAMAccountName
$usrArray += $usrArraydet 

# Loop to add the users in question to the group in question

$groupadd = $usrArray | ForEach-Object{
	
	$user = $_.sAMAccountName
	
	Add-ADGroupMember -Identity $group -Members $user
	
}