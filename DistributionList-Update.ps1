# Build Arrays of users from Active Directory who are enabled and who are from the Offices and Locations for each distribution list.
# It's critically important to remember that this script will only edit Old-Fashioned distribution lists in Exchange Online. A different cmdlet set is required for modifying Microsoft 365 Groups

$region1 = @()
$1det = Get-ADuser -Filter {Enabled -eq $True} -Properties UserPrincipalName,PhysicalDeliveryOfficeName,sAMAccountName | Select-Object UserPrincipalName,PhysicalDeliveryOfficeName | Where {$_.PhysicalDeliveryOfficeName -like "*PrimaryLocationName*"}
$region1 += $1det

$region2 = @()
$2det = Get-ADuser -Filter {Enabled -eq $True} -Properties UserPrincipalName,PhysicalDeliveryOfficeName,sAMAccountName | Select-Object UserPrincipalName,PhysicalDeliveryOfficeName | Where {$_.PhysicalDeliveryOfficeName -like "*loc1*" -or $_.PhysicalDeliveryOfficeName -like "*loc2*" -or $_.PhysicalDeliveryOfficeName -like "*loc3*" -or $_.PhysicalDeliveryOfficeName -like "*loc3*"}
$region2 += $2det

$region3 = @()
$3det = Get-ADuser -Filter {Enabled -eq $True} -Properties UserPrincipalName,PhysicalDeliveryOfficeName,sAMAccountName | Select-Object UserPrincipalName,PhysicalDeliveryOfficeName | Where {$_.PhysicalDeliveryOfficeName -like "*loc4*" -or $_.PhysicalDeliveryOfficeName -like "*loc5*" -or $_.PhysicalDeliveryOfficeName -like "*loc6*" -or $_.PhysicalDeliveryOfficeName -like "*loc7*" -or $_.PhysicalDeliveryOfficeName -like "*loc8*"}
$distro3 += $3det

$region4 =@()
$4det = Get-ADuser -Filter {Enabled -eq $True} -Properties UserPrincipalName,PhysicalDeliveryOfficeName,sAMAccountName | Select-Object UserPrincipalName,PhysicalDeliveryOfficeName | Where {$_.PhysicalDeliveryOfficeName -like "*loc9*" -or $_.PhysicalDeliveryOfficeName -like "*loc10*" -or $_.PhysicalDeliveryOfficeName -like "*loc11*" -or $_.PhysicalDeliveryOfficeName -like "*loc12*" -or $_.PhysicalDeliveryOfficeName -like "*loc13*"}
$region4 += $4det

$region5 = @()
$5det = Get-ADUser -Filter {Enabled -eq $True} -Properties UserPrincipalName,PhysicalDeliveryOfficeName,sAMAccountName | Select-Object UserPrincipalName,PhysicalDeliveryOfficeName | Where {$_.PhysicalDeliveryOfficeName -like "*loc14*" -or $_.PhysicalDeliveryOfficeName -like "*loc15*"}
$region5 += $5det

#Get all active user accounts from Active Directory, removing any known service and test accounts

$rmaccts = @('account1','account2','account3')
$accounts = Get-ADuser -SearchBase "OU=Lowest OU,OU=Top OU,DC=yourdomain,DC=dotcom" -Filter {Enabled -eq $True} -Properties name,sAMAccountName,UserPrincipalName | Select-Object name,sAMAccountName,UserPrincipalName | Where-Object {$_.DistinguishedName -notlike "*Test Users*" -and $_.DistinguishedName -notlike "*IT-TestUsers*" -and $_.DistinguishedName -notlike "*AnotherTestGroup*"} | Where {$rmaccts -notcontains $_.sAMAccountName -and $_.name -notlike "*test*" -and $_.name -notlike "*BeSpecific*"}

# Definition of global variables that will allow secured connection to Exchange Online using designated service account and encrypted passkeys. Error Actions silenced to allow script to run without breaking.

$365uname = "youradmin@yourdomain.com"
$AESKey = Get-Content "\\your\file\path\AES_file.key"
$pass = Get-Content "\\your\file\path\encrypted_password.txt"
$securePwd = $pass | ConvertTo-SecureString -Key $AESKey
$365cred = New-Object System.Management.Automation.PSCredential -ArgumentList $365uname, $securePwd
$ErrorActionPreference = 'SilentlyContinue'

# Initiate the O365 powershell session

$ExchangeSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "https://outlook.office365.com/powershell-liveid" -Credential $365cred -Authentication "Basic" -AllowRedirection
Import-PSSession $ExchangeSession -AllowClobber

# This loop updates the All Employees DIstro list

$allemployees = "allemployees@yourdomain.com"

$accounts | ForEach-Object{
	
	$user = $_.UserPrincipalName
	Add-DistributionGroupMember -Identity $allemployees -Member $user -Confirm:$false
	
}

# Primary Location Distro List

$primarygroup = "yourprimarygroup@yourdomain.com"

$region1 | ForEach-Object{
	
	    $user = $_.UserPrincipalName
        Add-DistributionGroupMember -Identity $primarygroup -Member $user -Confirm:$false
		
}

# Region 2 Distro list

$region2group = "yourregion2@yourdomain.com"

$region2 | ForEach-Object{
	
	    $user = $_.UserPrincipalName
        Add-DistributionGroupMember -Identity $region2group -Member $user -Confirm:$false
		
}

# Region 3 Distro list

$region3group = "group3@yourdomain.com"

$region3 | ForEach-Object{
	
	    $user = $_.UserPrincipalName
        Add-UnifiedGroupLinks -Identity $region3group -LinkType Members -Links $user
		
}

# Region 4 Distro List

$region4group = "group4@yourdomain.com"

$region4 | ForEach-Object{
	
		$user = $_.UserPrincipalName
		Add-UnifiedGroupLinks -Identity $region4group -LinkType Members -Links $user
		
}

# Region 5 Distro List

$region5group = "group5@yourdomain.com"

$region5 | ForEach-Object{
	
		$user = $_.UserPrincipalName
		Add-UnifiedGroupLinks -Identity $region5 -LinkType Members -Links $user
		
}

# Clean up the powershell session upon completion
Remove-PSSession outlook.office365.com
